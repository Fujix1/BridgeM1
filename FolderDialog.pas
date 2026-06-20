unit FolderDialog;

interface

uses
  Classes, FileCtrl;

type
  TFolderRoot = (rfDeskTop);

  TFolderDialog = class(TComponent)
  private
    FDirectory: string;
    FRootFolder: TFolderRoot;
    FTitle: string;
  public
    function Execute: Boolean;
  published
    property Directory: string read FDirectory write FDirectory;
    property RootFolder: TFolderRoot read FRootFolder write FRootFolder default rfDeskTop;
    property Title: string read FTitle write FTitle;
  end;

implementation

function TFolderDialog.Execute: Boolean;
var
  Dir: string;
begin
  Dir := FDirectory;
  Result := SelectDirectory(FTitle, '', Dir);
  if Result then
    FDirectory := Dir;
end;

initialization
  RegisterClasses([TFolderDialog]);

end.
