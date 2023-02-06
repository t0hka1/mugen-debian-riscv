import org.testng.annotations.Test;
import org.testng.annotations.BeforeSuite;
import org.testng.annotations.AfterSuite;

public class TExpTh5 {
	private double beforetime;
	private double aftertime;

	@Test(invocationCount = 3900, threadPoolSize = 3900)
	public void testMethod() {
		System.out.println("Thread Id :" + Thread.currentThread().getId());
	}

	@BeforeSuite
	public void beforetest() {
		this.beforetime = System.currentTimeMillis();

	}

	@AfterSuite
	public void aftertest() {
		this.aftertime = System.currentTimeMillis();
		System.out.println("time is :" + (aftertime - beforetime));
	}
}