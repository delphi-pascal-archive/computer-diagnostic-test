unit folders;

interface

uses SysUtils, Dialogs, Classes;

Function RemoveDirs(RootDir : String) : Boolean;//������� ����� � �� ����������
Function FileCopying(Source : String; Destination : String) : Boolean;//�������� �����
Function CopyDirs(DirSource : String; DirDest : String) : Boolean;//�������� �����
Function Get_Extention(path:string):String;//���������� ���������� �����
Function step_back(path:string):String;//�� ������� ����
Function get_name(path:string):String;//��� �����
Function check_path(path:string):String;//�������� �����

implementation

Function check_path(path:string):String;//�� ������� ����
var i,le:integer;
begin
  le:=length(path);
  if (path[le]='\') or (path[le]='/') then Result:=copy(path,1,le-1) else Result:=path;
end;

Function step_back(path:string):String;//�� ������� ����
var i,le:integer;
begin

  le:=length(path);

  for i:=0 to le-1 do
    if (path[le-i]='\') or (path[le-i]='/') then
      begin
        path:=copy(path,1,le-i-1);
        Break;
      end
    else
      begin
        if path[le-i]=':' then Break;
      end;
   Result:=path;
end;

Function get_name(path:string):String;//��� �����
var i,le:integer;
ori:string;
begin

  ori:=path;
  le:=length(path);

  for i:=0 to le-1 do
    if (path[le-i]='\') or (path[le-i]='/') then
      begin
        path:=copy(path,1,le-i-1);
        Break;
      end
    else
      begin
        if path[le-i]=':' then Break;
      end;

   Result:=copy(ori,length(path)+2,length(ori)-length(path));

end;

Function FileCopying(Source : String; Destination : String) : Boolean;//�������� �����
var s,d,t:integer;
  buf:array[0..127] of char;
begin

  s:=FileOpen(Source,fmOpenRead);
  if s=0 then
    begin
      ShowMessage('���� ' + Source+' �� ����������');
      Result:=false;
      exit;
    end;

  if FileExists(Destination) then DeleteFile(Destination);
  d:=FileCreate(Destination,fmCreate);

  if (s<>-1) and (d<>-1) then begin

    t:=FileRead(s,buf[0],128);
    while t<>0 do
      begin
        FileWrite(d,buf[0],t);
        t:=FileRead(s,buf[0],128);
      end;

    Result:=true;
  end else begin
    ShowMessage('�� �������� ����������� ' + Source);
    Result:=false;
  end;

  FileSetAttr(Destination, FileGetAttr(Source));

  FileClose(s);
  FileClose(d);

end;

Function Get_Extention(path:string):String;//���������� ���������� �����
var i,le:integer;
begin

  le:=length(path);

  for i:=1 to le do
    if path[le-i]='.' then
      begin
        path:=copy(path,le-i+1,i+1);
        Break;
      end;

   Result:=path;
 end;

Function RemoveDirs(RootDir : String) : Boolean;//������� ����� � �� ����������
var
  iIndex : Integer;
  SearchRec : TSearchRec;
  sFileName : string;
  StopLine:string;
  SourceDir:string;

  clear:boolean;

begin

  if NOT DirectoryExists(RootDir) then
    begin
      ShowMessage('����� ' + RootDir+' �� ����������');
      Result:=false;
      exit;
    end;

  iIndex:= FindFirst(RootDir+'\*.*', faAnyFile, SearchRec);
  clear:=true;

    while iIndex=0 do
      begin
        sFileName := RootDir+'\'+SearchRec.Name;
          if (SearchRec.Attr >= faDirectory) and (SearchRec.Attr < faArchive) then
            begin
               if (SearchRec.Name<>'') and (SearchRec.Name<>'.') and (SearchRec.Name<>'..') then
                 begin
                   if NOT RemoveDirs(sFileName) then
                     begin
                       clear:=false;
                       ShowMessage('�� �������� ������� ' + sFileName);
                     end;
                    iIndex := FindNext(SearchRec);
                 end else iIndex := FindNext(SearchRec);
            end else
              begin
                 if NOT DeleteFile(sFileName) then
                   begin
                     clear:=false;
                     ShowMessage('�� �������� ������� ' + sFileName);
                   end;
                 iIndex := FindNext(SearchRec);
              end;
      end;


    FindClose(SearchRec);

    if NOT RemoveDir(RootDir) then
      begin
        clear:=false;
        ShowMessage('�� �������� ������� ' + RootDir);
      end;

    Result:=clear;

end;

Function CopyDirs(DirSource : String; DirDest : String) : Boolean;//�������� �����
var
  iIndex : Integer;
  SearchRec : TSearchRec;
  sFileName : string;
  dFileName : string;
  clear:boolean;

  what:integer;

begin

  if NOT DirectoryExists(DirSource) then
    begin
      ShowMessage('����� ' + DirSource+' �� ����������');
      Result:=false;
      exit;
    end;

  if NOT DirectoryExists(DirDest) then
    if NOT CreateDir(DirDest) then
      begin
        ShowMessage('�� �������� ������� ����� ' + DirDest);
        Result:=false;
        exit;
      end;

  FileSetAttr(DirDest,FileGetAttr(DirSource));

  iIndex:= FindFirst(DirSource+'\*.*', faAnyFile, SearchRec);
  clear:=true;

    while iIndex=0 do
      begin
        sFileName := DirSource+'\'+SearchRec.Name;
        dFileName := DirDest+'\'+SearchRec.Name;
          if (SearchRec.Attr >= faDirectory) and (SearchRec.Attr < faArchive) then
            begin
               if (SearchRec.Name<>'') and (SearchRec.Name<>'.') and (SearchRec.Name<>'..') then
                 begin
                   if NOT CopyDirs(sFileName,dFileName) then
                     begin
                       clear:=false;
                       ShowMessage('�� �������� ���������� ' + sFileName);
                     end;
                    iIndex := FindNext(SearchRec);
                 end else iIndex := FindNext(SearchRec);
            end else
              begin
                 if NOT FileCopying(sFileName,DirDest+'\'+SearchRec.Name) then
                   begin
                     clear:=false;
                     ShowMessage('�� �������� ���������� ' + sFileName);
                   end;
                 iIndex := FindNext(SearchRec);
              end;
      end;
    FindClose(SearchRec);
    Result:=clear;

end;



end.
