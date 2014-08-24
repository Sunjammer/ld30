package furusystems.cw.colors;

/**
 * ...
 * @author Andreas Rønning
 */
class Palette
{
	public var colors:Array<Int>;
	public var complimentaries:Array<Int>;
	public function new(a:Array<Int>, b:Array<Int>) 
	{
		colors = a;
		complimentaries = b;
	}
	
}