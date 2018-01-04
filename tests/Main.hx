package ;

import uhx.jwenn.*;
import utest.Runner;
import utest.ui.Report;

class Main {
	
	@:keep public static function main() {
		var runner = new Runner();
		runner.addCase(new JsonQuerySpec());
		runner.addCase(new HtmlQuerySpec());
		Report.create(runner);
		runner.run();
	}
	
}
