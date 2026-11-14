"""Run once on a fresh sample database."""
import os
import subprocess
import time

PSQL = ["psql", "-X", "-qAt", "-v", "ON_ERROR_STOP=1"]
TAKE = "UPDATE products SET stock = stock - 1 WHERE product_id = 1 AND stock > 0 RETURNING stock"


def query(sql):
    return subprocess.check_output([*PSQL, "-c", sql], text=True, timeout=12).strip()


def expect(label, value, wanted):
    if value != wanted:
        raise AssertionError(f"{label}: expected {wanted!r}, got {value!r}")
    print(f"{label}: {value}", flush=True)


def demo():
    with subprocess.Popen(PSQL, stdin=subprocess.PIPE, stdout=subprocess.PIPE, text=True) as a:
        def send(sql):
            a.stdin.write(sql + ";\n")
            a.stdin.flush()
        def read():
            return a.stdout.readline().strip()
        try:
            send("BEGIN ISOLATION LEVEL READ COMMITTED")
            send(TAKE)
            expect("A sees stock inside its open transaction", read(), "0")
            send("INSERT INTO orders (order_id, customer_id) VALUES (101, 1)")
            send("INSERT INTO order_items VALUES (101, 1, 1, 450000)")
            expect("Another connection sees committed stock before A commits",
                   query("SELECT stock FROM products WHERE product_id=1"), "1")
            expect("Another connection sees order 101 before commit",
                   query("SELECT count(*) FROM orders WHERE order_id=101"), "0")

            env = {**os.environ, "PGAPPNAME": "temu_demo_buyer_b"}
            with subprocess.Popen([*PSQL, "-c", TAKE], stdout=subprocess.PIPE, text=True, env=env) as b:
                try:
                    for _ in range(70):
                        wait = query("SELECT wait_event_type FROM pg_stat_activity WHERE application_name='temu_demo_buyer_b'")
                        if wait == "Lock":
                            print("B waits for the stock row lock", flush=True)
                            break
                        if b.poll() is not None:
                            raise AssertionError("B completed before A committed")
                        time.sleep(0.1)
                    else:
                        raise AssertionError("B did not wait for the stock row")
                    send("COMMIT")
                    result, _ = b.communicate(timeout=12)
                    assert b.returncode == 0
                    expect("B receives no stock row after A commits", result.strip(), "")
                finally:
                    if b.poll() is None:
                        b.kill()

            expect("Committed order 101 is visible", query("SELECT count(*) FROM orders WHERE order_id=101"), "1")
            expect("Stock left for iPhone 18", query("SELECT stock FROM products WHERE product_id=1"), "0")
            expect("Total orders after the race", query("SELECT count(*) FROM orders"), "1")
            send("BEGIN")
            send("UPDATE products SET stock=stock-1 WHERE product_id=2 RETURNING stock")
            expect("Power bank stock inside the rollback example", read(), "11")
            send("INSERT INTO orders (order_id, customer_id) VALUES (102, 2)")
            send("INSERT INTO order_items VALUES (102, 2, 1, 8500)")
            send("ROLLBACK")
            send("SELECT stock FROM products WHERE product_id=2")
            expect("Power bank stock after rollback", read(), "12")
            expect("Order 102 after rollback", query("SELECT count(*) FROM orders WHERE order_id=102"), "0")
        finally:
            a.stdin.close()
            try:
                a.wait(timeout=12)
            except subprocess.TimeoutExpired:
                a.kill()
                a.wait()
        assert a.returncode == 0


if __name__ == "__main__":
    demo()
