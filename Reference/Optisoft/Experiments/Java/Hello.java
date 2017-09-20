public class Hello {

	public static void main(String args[]) {

		for (int i = 0; i < args.length; i++) System.out.println(args[i]);

		Foo foo = new Foo();
		foo.foo();

		Bar bar = new Bar();
		int i = bar.bar(1);

		System.out.println("Bar returned " + i);

		Thread thread = new Thread(new Baz());
		thread.start();

		System.out.println("Hello, world!!!");
		System.out.println("The thread is running now, world!!!");
	}
}
