unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, jpeg, ExtCtrls, Buttons, ComCtrls, Folders;

type
  TForm1 = class(TForm)
    Image1: TImage;
    Label1: TLabel;
    ComboBox1: TComboBox;
    Label2: TLabel;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Image2: TImage;
    procedure BitBtn3Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure ComboBox1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ComboBox1KeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }

    //Формирование динамических компонентов для отображения вопроса и его критериев
    procedure CaseOrder(Source: TTreeNode);

    //Автоматический перенос с заданной длиной строки
    function ReShift(S:string;line_length:integer):string;

    //Данные результата без вероятности
    function SCL(S:string):string;

    //Вероятность результата
    function SCP(S:string):string;

    //Перехватчик для события нажатия кнопки мыши для динамического объекта класса TCheckBox
    procedure SnapeOrder(Sender: TObject);

    //Перехватчик для события нажатия кнопки мыши для динамического объекта класса TLabel
    procedure Long_hands(Sender: TObject);

  end;

var
  Form1: TForm1;
  TV:TTreeView;
  path:string;

  list:array of String;
  list_count:integer;

  ch_var:array of TCheckBox;
  ch_count:integer;
  str_var:array of TLabel;

  MNODE:TTreeNode;

implementation

{$R *.dfm}

function TForm1.SCL(S:string):string;
var i:integer;
begin

  for i:=1 to length(S) do begin
    if s[i]='[' then begin
      SCL:=copy(S,1,i-1);
      exit;
    end;
  end;

  SCL:=S;

end;

function TForm1.SCP(S:string):string;
var i,a,b:integer;
begin

  for i:=1 to length(S) do begin
    if s[i]='[' then a:=i+1;

    if s[i]=']' then begin
      b:=i;
      SCP:=copy(S,a,b-a);
      exit;
    end;

  end;

  SCP:='';
end;

procedure TForm1.Long_hands(Sender: TObject);
var i:integer;
begin

  for i:=1 to ch_count do begin
      if str_var[i-1]=Sender then ch_var[i-1].Checked:=not(ch_var[i-1].Checked);
  end;

end;

procedure TForm1.SnapeOrder(Sender: TObject);
var i:integer;
begin

  for i:=1 to ch_count do begin
    if ch_var[i-1]<>Sender then ch_var[i-1].Checked:=false;
  end;

  BitBtn2.Enabled:=false;
  for i:=1 to ch_count do begin
    if ch_var[i-1].Checked then begin
      BitBtn2.Enabled:=true;
    end;
  end;

end;

function TForm1.ReShift(S:string;line_length:integer):string;
var counter,mark,i:integer;
SR:string;
begin
  if pos('&',S)<>0 then
   begin
   Image2.Picture.LoadFromFile(ExtractFilePath(Application.ExeName)+'jpeg\'+copy(S,pos('&',S)+1,Length(S)-pos('&',S)+1));
   Delete(S,pos('&',S),Length(S)-pos('&',S)+1);
   end;
  counter:=0;
  mark:=0;
  SR:='';
  for i:=1 to length(S) do begin

    SR:=SR+S[i];
    if S[i]=' ' then mark:=i;

    inc(counter);
    if counter>line_length then begin

      if mark=0 then begin
        SR:=SR+chr(13);
      end else begin
        SR:=copy(SR,1,length(SR)-(i-mark))+chr(13)+copy(SR,length(SR)-(i-mark)+1,(i-mark));
      end;

      counter:=0;
    end;

  end;

  Result:=SR;

end;

procedure TForm1.BitBtn2Click(Sender: TObject);
var i,k:integer;
s:string;
r:real;
begin
  Bitbtn3.Enabled:=true;
  Bitbtn2.Enabled:=false;

  for i:=1 to ch_count do begin
    if ch_var[i-1].Checked then k:=i;
  end;

  MNODE:=MNODE.Item[k];

  if MNODE.Count=1 then begin
    for i:=1 to ch_count do begin
      ch_var[i-1].Enabled:=false;
    end;

    label4.Caption:=ReShift(SCL(MNODE.Item[0].Text),35);
    label4.visible:=true;
    label3.Visible:=true;

    s:=SCP(MNODE.Item[0].Text);
    if s<>'' then begin

      label5.Visible:=true;
      try
        r:=Strtofloat(copy(s,1,length(s)-1));
        except
        on E: Exception do label5.Visible:=false;
      end;

      label5.top:=label4.Top+label4.Height+8;
      label5.Caption:='Вероятность '+s;
      label5.Font.Color:=rgb(round(r*2.55),0,0);

    end;

    BitBtn2.Enabled:=false;

  end else begin
    CaseOrder(MNODE);
  end;

end;

procedure TForm1.BitBtn3Click(Sender: TObject);

begin

  label3.Visible:=false;
  label4.Visible:=false;
  label5.Visible:=false;

  BitBtn2.Enabled:=false;

  MNODE:=MNODE.parent;
  if MNODE.Level=0 then BitBtn3.Enabled:=false;

  CaseOrder(MNODE);

end;

procedure TForm1.CaseOrder(Source: TTreeNode);
var i:integer;
begin

  for i:=1 to ch_count do begin
    ch_var[i-1].Free;
    str_var[i-1].Free;
  end;

  SetLength(ch_var,Source.Count-1);
  SetLength(str_var,Source.Count-1);

  ch_count:=Source.Count-1;

  for i:=2 to Source.Count do begin

    ch_var[i-2]:=TCheckBox.Create(Self);
    ch_var[i-2].Parent:=form1;
    ch_var[i-2].Caption:='';
    ch_var[i-2].Left:=8+10;
    ch_var[i-2].Height:=14;
    ch_var[i-2].Width:=14;
    ch_var[i-2].Top:=(i-1)*60+400;
    ch_var[i-2].OnClick:=SnapeOrder;


    str_var[i-2]:=TLabel.Create(Self);
    str_var[i-2].Parent:=form1;
    str_var[i-2].Left:=25+10;
    str_var[i-2].Height:=14;
    str_var[i-2].Width:=520;
    str_var[i-2].Top:=(i-1)*60+400;
    str_var[i-2].Transparent:=true;
    str_var[i-2].Caption:=ReShift(Source.Item[i-1].text,80);
    str_var[i-2].OnClick:=Long_hands;

  end;

  Label2.Caption:=ReShift(Source.Item[0].text,45);

end;

procedure TForm1.BitBtn1Click(Sender: TObject);
begin

  if Combobox1.ItemIndex<>-1 then begin
    bitbtn2.Visible:=true;
    bitbtn3.Visible:=true;

    label3.Visible:=false;
    label4.Visible:=false;
    label5.Visible:=false;

    BitBtn2.Enabled:=false;
    BitBtn3.Enabled:=false;

    TV.LoadFromFile(list[Combobox1.ItemIndex]);
    MNODE:=TV.items.Item[0];
    CaseOrder(MNODE);

  end;

end;

procedure TForm1.ComboBox1Change(Sender: TObject);
begin
  if ComboBox1.ItemIndex<>-1 then Bitbtn1.Enabled:=true;

end;

procedure TForm1.ComboBox1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  key:=word(#0);
end;

procedure TForm1.ComboBox1KeyPress(Sender: TObject; var Key: Char);
begin
  Key:=#0;
end;

procedure TForm1.FormCreate(Sender: TObject);
var home:string;

  iIndex : Integer;
  SearchRec : TSearchRec;
  sFileName : string;
  StopLine:string;
  SourceDir:string;

  clear:boolean;
  RootDir : String;

begin

  label2.caption:='Ожидание инструкции';

  ch_count:=0;

  list_count:=0;

  path:=ExtractFilePath(Application.EXEName);

  home:=path+'Instructions\';

  if not(DirectoryExists(home)) then begin
    CreateDir(home);
    MessageDlg('Нет инструкции! Определите инструкции используя конструктор.', mtWarning, [mbOK], 0);
  end;

  TV:=TTreeView.Create(Self);
  TV.Parent :=form1;
  TV.Visible:=false;

  RootDir:=home;

  iIndex:= FindFirst(RootDir+'\*.*', faAnyFile, SearchRec);
  clear:=true;

  while iIndex=0 do
    begin
      sFileName := RootDir+'\'+SearchRec.Name;

        if SearchRec.Attr = faArchive then begin

          if Get_Extention(sFileName)='tree' then begin

            inc(list_count);
            SetLength(list,list_count);

            TV.LoadFromFile(sFileName);

            list[list_count-1]:=sFileName;

            Combobox1.Items.Add(TV.items.Item[0].Text);

          end;
        end;

        iIndex := FindNext(SearchRec);
    end;

  FindClose(SearchRec);

  Combobox1.Text:='Выберите соответсвующий раздел (систему)'; 

end;

end.
