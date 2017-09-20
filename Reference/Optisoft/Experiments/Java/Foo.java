public class Foo {

	void foo() { System.out.println("Foo"); }
}

class Bar {

	int bar(int bar) { return bar + 31337; }
}

class Baz implements Runnable {

	public void run() {

		for (int i = 0; i < 256; i++) {
			
			System.out.println("Running");

			try {
				Thread.sleep(1000);
			}

			catch (InterruptedException e) {

				System.out.println("Interrupted");
			}
		}
	}
}
