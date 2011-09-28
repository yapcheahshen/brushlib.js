{
  https://github.com/yapcheahshen/brushlib.js
}

program myb2json;

{$APPTYPE CONSOLE}
{$IFDEF FPC}
{$MODE DELPHI}
{$ENDIF}

uses
  SysUtils,classes,brush_myb,brush_mapping;
var
  mappings: array [0..BRUSH_SETTINGS_COUNT-1] of TMyBrushmapping;
  myb,output:tstringlist;
  i,j,k,n:integer;
  x,y:single;
  s,extra,brushname:string;
begin
  if paramcount<1 then begin
    writeln('myb2json name.myb');
    writeln('  output name.myb.js');
    exit;
  end;

  myb:=tstringlist.create;
  output:=tstringlist.create;
  myb.loadfromfile(paramstr(1));
  brushname:=extractfilename(paramstr(1));
  brushname:=copy(brushname,1,length(brushname)-4);
  for i:=0 to BRUSH_SETTINGS_COUNT-1 do begin
    mappings[i]:=TMyBrushmapping.create(BRUSH_INPUT_COUNT);
  end;
  readmyb( myb, mappings);

  output.add('var '+brushname+'={');
  for i:=0 to BRUSH_SETTINGS_COUNT-1 do begin
    s:=setting2name(i)+':{';
    s:= s+format('base_value:%2.3f',[mappings[i].base_value]);
    extra:='';
    for j:=0 to mappings[i].get_inputs-1 do begin
      n:=mappings[i].get_n(j);
      if n>0 then begin
        if extra<>'' then extra:=extra+',';
        extra:=extra+input2name(j)+':[';
        for k:=0 to n-1 do begin
          if k>0 then extra:=extra+',';
          mappings[i].get_point(j,k,x,y);
          extra:=extra+format('%2.3f,%2.3f',[x,y]);
        end;
        extra:=extra+']';
      end;
    end;
    if extra<>'' then begin
      s:=s+',pointsList:{'+extra+'}';
    end;

    if i<BRUSH_SETTINGS_COUNT-1 then s:=s+'},'
    else s:=s+'}';
    output.add(s);
  end;
  output.add('} ;');

  myb.free;
  output.savetofile(paramstr(1)+'.js');
  output.free;
end.
