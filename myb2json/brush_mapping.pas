{
  https://github.com/yapcheahshen/brushlib.js
}


unit brush_mapping;

interface
type
  TMyBrushMapping_ControlPoints=record
    xvalues: array [0..7] of single;
    yvalues: array [0..7] of single;
    n:integer;
  end;

  PMyBrushMapping_ControlPoints = ^TMyBrushMapping_ControlPoints;
  TMyBrushMapping=class(tobject)
    private
    inputs:Integer;
    inputs_used:integer; // optimization

    public
    base_value:single;
    pointsList: array of TMyBrushMapping_ControlPoints;
    
    constructor create(inputcount:integer);
    procedure set_n(input,n:integer);
    function get_n(input:integer):integer;
    function get_inputs:integer;
    procedure set_point(input,index:integer;x,y:single);
    procedure get_point(input,index:integer;var x,y:single);
    function calculate_single_input(input:single):single;
    function calculate (data: array of single):single;
    function is_constant:boolean;
    procedure updated;
  end;

  PMyBrushMapping=^TMyBrushMapping;


implementation

{ TMyBrushMapping }

function TMyBrushMapping.calculate(data: array of single): single;
var
  i,j:integer;
  x,y:single;
  x0, y0, x1, y1:single;
  p:PMyBrushMapping_ControlPoints;
begin
  result := base_value;

  // constant mapping (common case)
  if (inputs_used = 0) then exit;

  for j:=0 to inputs-1 do begin
    p:=@pointsList[j];

    if (p.n=0) then continue;
    x := data[j];

      // find the segment with the slope that we need to use
    x0 := p.xvalues[0];
    y0 := p.yvalues[0];
    x1 := p.xvalues[1];
    y1 := p.yvalues[1];

    i:=2;
    while (i<p.n) and (x>x1) do  begin
      x0 := x1;
      y0 := y1;
      x1 := p.xvalues[i];
      y1 := p.yvalues[i];
      inc(i);
    end;

    if (x0 = x1) then begin
      y := y0;
    end else begin
        // linear interpolation
        y := (y1*(x - x0) + y0*(x1 - x)) / (x1 - x0);
    end;

    result :=result+ y;
  end;
end;

function TMyBrushMapping.calculate_single_input (input:single):single;
var
  ip:array [0..1] of single;
begin
  assert(inputs = 1);
  ip[0]:=input;
  result:=calculate(ip);
end;

constructor TMyBrushMapping.create(inputcount: integer);
var
  i:integer;
begin
  inputs := inputcount;
  setlength(pointsList,inputs);
  for i:=0 to inputs-1 do begin
    pointsList[i].n := 0;
  end;
  inputs_used := 0;
  base_value := 0;
end;

function TMyBrushMapping.is_constant: boolean;
begin
  result:= inputs_used = 0;
end;
function TMyBrushMapping.get_n(input: integer):integer;
begin
  result:=pointsList[input].n;
end;

procedure TMyBrushMapping.set_n(input, n: integer);
var
  p:PMyBrushMapping_ControlPoints;
begin
  assert ((input >= 0) and (input < inputs));
  assert ((n >= 0) and (n <= 8));
  assert ( n <> 1); // cannot build a linear mapping with only one point
  p:=@pointsList[input];

//  if (( n <> 0 ) and ( p.n = 0)) then inc(inputs_used);
//  if ( (n = 0 ) and ( p.n <> 0)) then dec(inputs_used);

//  assert(inputs_used >= 0);
//  assert(inputs_used <= inputs);

  p.n := n;
end;

procedure TMyBrushMapping.set_point(input, index: integer; x, y: single);
var
  p:PMyBrushMapping_ControlPoints;
begin
  assert ((input >= 0) and (input < inputs));
  assert ((index >= 0) and (index <= 8));
  p:=@pointsList[input];
  assert (index < p.n);

  if (index > 0) then assert (x >= p.xvalues[index-1]);

  p.xvalues[index] := x;
  p.yvalues[index] := y;
end;

procedure TMyBrushMapping.get_point(input,index:integer;var x,y:single);
var
  p:PMyBrushMapping_ControlPoints;
begin
  assert ((input >= 0) and (input < inputs));
  assert ((index >= 0) and (index <= 8));
  p:=@pointsList[input];
  assert (index < p.n);

  if (index > 0) then assert (x >= p.xvalues[index-1]);

  x:=p.xvalues[index];
  y:=p.yvalues[index];
end;

function TMyBrushMapping.get_inputs: integer;
begin
  result:=inputs;
end;


procedure TMyBrushMapping.updated;
var
  i:integer;
begin
  inputs_used:=0;
  for i:=0 to inputs-1 do begin
    if (pointsList[i].n>0) then inc(inputs_used);
  end;
end;

end.

