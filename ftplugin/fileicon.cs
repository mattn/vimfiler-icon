using System;
using System.Drawing;
using System.IO;

public class ExtractIcon {
	public static void Main(string[] args) {
		try {
			using (Icon ico = Icon.ExtractAssociatedIcon(args[0])) {
				using (FileStream stm = new FileStream(
							args[1], FileMode.CreateNew)) {
					ico.Save(stm);
				}
			}
		} catch (Exception e) {
			Console.WriteLine(e.ToString());
			Environment.Exit(1);
		}
	}
}
