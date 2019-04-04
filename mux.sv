module mux
	(output logic [64-1:0] f,
	input logic [64-1:0] a,b,
	input logic sel);

  and g1(f1,a,n_sel),
      g2(f2,b,sel);
   or g3(f,f1,f2);
  not g4(n_sel,sel);

endmodule