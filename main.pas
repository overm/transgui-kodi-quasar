{*************************************************************************************
  This file is part of Transmission Remote GUI.
  Copyright (c) 2008-2019 by Yury Sidorov and Transmission Remote GUI working group.

  Transmission Remote GUI is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.

  Transmission Remote GUI is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with Transmission Remote GUI; if not, write to the Free Software
  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

  In addition, as a special exception, the copyright holders give permission to 
  link the code of portions of this program with the
  OpenSSL library under certain conditions as described in each individual
  source file, and distribute linked combinations including the two.

  You must obey the GNU General Public License in all respects for all of the
  code used other than OpenSSL.  If you modify file(s) with this exception, you
  may extend this exception to your version of the file(s), but you are not
  obligated to do so.  If you do not wish to do so, delete this exception
  statement from your version.  If you delete this exception statement from all
  source files in the program, then also delete it here.
*************************************************************************************}
unit Main;
{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, zstream, LResources, Forms, Controls,
  {$ifdef windows}
  windows, ShellApi,
  {$else}
  lclintf,
  {$endif windows}
  Graphics, Dialogs, ComCtrls, Menus, ActnList, LCLVersion,
  httpsend, StdCtrls, fpjson, jsonparser, ExtCtrls, rpc, syncobjs, variants, varlist, IpResolver,
  zipper, ResTranslator, VarGrid, StrUtils, LCLProc, Grids, BaseForm, utils, AddTorrent, Types,
  LazFileUtils, LazUTF8, StringToVK, passwcon, GContnrs,lineinfo, RegExpr;

const
  AppName = 'Transmission Remote GUI KODI mode';
  AppVersion = '5.18.3';

resourcestring
  sAll = 'All torrents';
  sWaiting = 'Waiting';
  sVerifying = 'Verifying';
  sDownloading = 'Downloading';
  sSeeding = 'Seeding';
  sFinished = 'Finished';
  sStopped = 'Stopped';
  sUnknown = 'Unknown';
  sCompleted = 'Completed';
  sConnected = 'connected';
  sActive = 'Active';
  sInactive = 'Inactive';
  sErrorState = 'Error';
  sUpdating = 'Updating...';
  sFinishedDownload = '''%s'' has finished downloading';
  sDownloadComplete = 'Download complete';
  sUpdateComplete = 'Update complete.';
  sTorrentVerification = 'Torrent verification may take a long time.' + LineEnding + 'Are you sure to start verification of torrent ''%s''?';
  sTorrentsVerification = 'Torrents verification may take a long time.' + LineEnding + 'Are you sure to start verification of %d torrents?';
  sReconnect = 'Reconnect in %d seconds.';
  sDisconnected = 'Disconnected';
  sConnectingToDaemon = 'Connecting to daemon...';
  sLanguagePathFile = 'Language pathfile';
  sLanguagePath = 'Language path';
  sLanguageList = 'Language list';
  sSecs = '%ds';
  sMins = '%dm';
  sHours = '%dh';
  sDays = '%dd';
  sMonths = '%dmo';
  sYears  = '%dy';
  sDownloadingSeeding = '%s%s%d downloading, %d seeding%s%s, %s';
  sDownSpeed = 'D: %s/s';
  sUpSpeed = 'U: %s/s';
  SFreeSpace = 'Free: %s';
  sNoPathMapping = 'Unable to find path mapping.'+LineEnding+'Use the application''s options to setup path mappings.';
  sGeoIPConfirm = 'Geo IP database is needed to resolve country by IP address.' + LineEnding + 'Download this database now?';
  sFlagArchiveConfirm = 'Flag images archive is needed to display country flags.' + LineEnding + 'Download this archive now?';
  sInSwarm = 'in swarm';
  sHashfails = '%s (%d hashfails)';
  sDone = '%s (%s done)';
  sHave = '%d x %s (have %d)';
  sUnableExtractFlag = 'Unable to extract flag image.';
  sTrackerWorking = 'Working';
  sTrackerUpdating = 'Updating';
  sRestartRequired = 'You need to restart the application to apply changes.';
  sRemoveTorrentData = 'Are you sure to remove torrent ''%s'' and all associated DATA?';
  sRemoveTorrentDataMulti = 'Are you sure to remove %d selected torrents and all their associated DATA?';
  sRemoveTorrent = 'Are you sure to remove torrent ''%s''?';
  sRemoveTorrentMulti = 'Are you sure to remove %d selected torrents?';
  sUnableGetFilesList = 'Unable to get files list';
  sTrackerError = 'Tracker';
  sSkip = 'skip';
  sLow = 'low';
  sNormal = 'normal';
  sHigh = 'high';
  sByte = 'b';
  sKByte = 'KB';
  sMByte = 'MB';
  sGByte = 'GB';
  sTByte = 'TB';
  sPerSecond = '/s';
  sOf = 'of';
  sNoTracker = 'No tracker';
  sTorrents = 'Torrents';
  sBlocklistUpdateComplete = 'The block list has been updated successfully.' + LineEnding + 'The list entries count: %d.';
  sSeveralTorrents = '%d torrents';
  sUnableToExecute = 'Unable to execute "%s".';
  sSSLLoadError = 'Unable to load OpenSSL library files: %s and %s';
  SRemoveTracker = 'Are you sure to remove tracker ''%s''?';
  SUnlimited = 'Unlimited';
  SAverage = 'average';
  SCheckNewVersion = 'Do you wish to enable automatic checking for a new version of %s?';
  SDuplicateTorrent = 'Torrent already exists in the list';
  SUpdateTrackers = 'Update trackers for the existing torrent?';
  SDownloadingTorrent = 'Downloading torrent file...';
  SConnectTo = 'Connect to %s';
  SEnterPassword = 'Please enter a password to connect to %s:';

  SDownloaded = 'Downloaded';
  SUploaded = 'Uploaded';
  SFilesAdded = 'Files added';
  SActiveTime = 'Active time';
  STotalSize = 'Total: %s';
  sTotalSizeToDownload = 'Selected: %s';
  sTotalDownloaded = 'Done: %s';
  sTotalRemain = 'Remaining: %s';

  sUserMenu = 'User Menu';

  sBiDiDefault = 'Default';
  sBiDiLeftRight = 'Left->Right';
  sBiDiRightLeft = 'Right->Left';
  sBiDiRightLeftNoAlign = 'Right->Left (No Align)';
  sBiDiRightLeftReadOnly = 'Right->Left (Reading Only)';

  sPrivateOn = 'ON';
  sPrivateOff = 'OFF';

type

  { TMyHashMap example from hashmapdemo }
  TMyHashMap = class(specialize TGenHashMap<Integer, Integer>)
    function DefaultHashKey(const Key: Integer): Integer; override;
    function DefaultKeysEqual(const A, B: Integer): Boolean; override;
    function DefaultKeyToString(const Key: Integer): String; override;
    function DefaultItemToString(const Item: Integer): String; override;
  end;

  // for torrent folder
  FolderData = class
  public
    Hit: integer;
    Ext: string;
    Txt: string;
    Lst: TDate;
  end;


  { TProgressImage }

  TProgressImage = class(TGraphicControl)
  private
    FBmp: TBitmap;
    FBorderColor: TColor;
    FEndIndex: integer;
    FImageIndex: integer;
    FImages: TImageList;
    FStartIndex: integer;
    FTimer: TTimer;
    function GetFrameDelay: integer;
    procedure SetBorderColor(const AValue: TColor);
    procedure SetEndIndex(const AValue: integer);
    procedure SetFrameDelay(const AValue: integer);
    procedure SetImageIndex(const AValue: integer);
    procedure SetImages(const AValue: TImageList);
    procedure SetStartIndex(const AValue: integer);
    procedure UpdateIndex;
    procedure DoTimer(Sender: TObject);
  protected
    procedure Paint; override;
    procedure VisibleChanged; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Images: TImageList read FImages write SetImages;
    property ImageIndex: integer read FImageIndex write SetImageIndex;
    property StartIndex: integer read FStartIndex write SetStartIndex;
    property EndIndex: integer read FEndIndex write SetEndIndex;
    property FrameDelay: integer read GetFrameDelay write SetFrameDelay;
    property BorderColor: TColor read FBorderColor write SetBorderColor;
  end;

  { TMainForm }

  TMainForm = class(TBaseForm)
    acConnect: TAction;
    acAddTorrent: TAction;
    acExport: TAction;
    acImport: TAction;
    acStopTorrent: TAction;
    acRemoveTorrent: TAction;
    acStartTorrent: TAction;
    acSetHighPriority: TAction;
    acSetNormalPriority: TAction;
    acSetLowPriority: TAction;
    acSetNotDownload: TAction;
    acOptions: TAction;
    acDaemonOptions: TAction;
    acStartAllTorrents: TAction;
    acStopAllTorrents: TAction;
    acExit: TAction;
    acResolveHost: TAction;
    acResolveCountry: TAction;
    acShowCountryFlag: TAction;
    acSetupColumns: TAction;
    acRemoveTorrentAndData: TAction;
    acOpenFile: TAction;
    acOpenContainingFolder: TAction;
    acAddLink: TAction;
    acReannounceTorrent: TAction;
    acMoveTorrent: TAction;
    acSelectAll: TAction;
    acShowApp: TAction;
    acHideApp: TAction;
    acAddTracker: TAction;
    acEditTracker: TAction;
    acDelTracker: TAction;
    acConnOptions: TAction;
    acNewConnection: TAction;
    acDisconnect: TAction;
    acAltSpeed: TAction;
    acForceStartTorrent: TAction;
    acQMoveTop: TAction;
    acQMoveUp: TAction;
    acQMoveDown: TAction;
    acQMoveBottom: TAction;
    acCheckNewVersion: TAction;
    acFolderGrouping: TAction;
    acAdvEditTrackers: TAction;
    acFilterPane: TAction;
    acMenuShow :  TAction;
    acBigToolbar: TAction;
    acSetLabels: TAction;
    acLabelGrouping: TAction;
    ImageList32: TImageList;
    MenuItem103: TMenuItem;
    MenuItem104: TMenuItem;
    MenuItem105: TMenuItem;
    MenuItem106: TMenuItem;
    MenuShow: TAction;
    ActionList1: TActionList;
    acToolbarShow :  TAction;
    acInfoPane: TAction;
    acStatusBar: TAction;
    acCopyPath: TAction;
    acRename: TAction;
    acStatusBarSizes: TAction;
    acTrackerGrouping: TAction;
    acUpdateBlocklist: TAction;
    acUpdateGeoIP: TAction;
    acTorrentProps: TAction;
    acVerifyTorrent: TAction;
    ActionList: TActionList;
    ApplicationProperties: TApplicationProperties;
    MenuItem501: TMenuItem;
    MenuItem502: TMenuItem;
    SearchToolbar: TToolBar;
    tbSearchCancel: TToolButton;
    LocalWatchTimer: TTimer;
    ToolButton10: TToolButton;
    txDummy1: TLabel;
    txMagLabel: TLabel;
    txMagnetLink: TEdit;
    MenuItem101: TMenuItem;
    MenuItem102: TMenuItem;
    edSearch: TEdit;
    imgSearch: TImage;
    imgFlags: TImageList;
    ImageList16: TImageList;
    FilterTimer: TTimer;
    MenuItem100: TMenuItem;
    MenuItem122: TMenuItem;
    MenuItem1888: TMenuItem;
    MenuItem1889: TMenuItem;
    MenuItem1890: TMenuItem;
    MenuItem68: TMenuItem;
    MenuItem93: TMenuItem;
    MenuItem94: TMenuItem;
    MenuItem95: TMenuItem;
    MenuItem96: TMenuItem;
    MenuItem97: TMenuItem;
    MenuItem98: TMenuItem;
    MenuItem99: TMenuItem;
    miExport: TMenuItem;
    miImport: TMenuItem;
    OpenDialog1: TOpenDialog;
    panDetailsWait: TPanel;
    SaveDialog1: TSaveDialog;
    ToolButton5: TToolButton;
    txGlobalStats: TLabel;
    lvFilter: TVarGrid;
    lvTrackers: TVarGrid;
    MenuItem25: TMenuItem;
    MenuItem34: TMenuItem;
    MenuItem35: TMenuItem;
    MenuItem40: TMenuItem;
    MenuItem41: TMenuItem;
    MenuItem43: TMenuItem;
    MenuItem63: TMenuItem;
    MenuItem64: TMenuItem;
    MenuItem77: TMenuItem;
    MenuItem78: TMenuItem;
    MenuItem79: TMenuItem;
    MenuItem80: TMenuItem;
    MenuItem81: TMenuItem;
    MenuItem82: TMenuItem;
    MenuItem83: TMenuItem;
    MenuItem84: TMenuItem;
    MenuItem85: TMenuItem;
    MenuItem86: TMenuItem;
    MenuItem87: TMenuItem;
    MenuItem88: TMenuItem;
    MenuItem89: TMenuItem;
    MenuItem90: TMenuItem;
    MenuItem91: TMenuItem;
    MenuItem92: TMenuItem;
    miView: TMenuItem;
    goDevelopmentSite: TMenuItem;
    miHomePage: TMenuItem;
    pmiQueue: TMenuItem;
    miQueue: TMenuItem;
    pmFilter: TPopupMenu;
    sepTrackers: TMenuItem;
    MenuItem65: TMenuItem;
    MenuItem66: TMenuItem;
    MenuItem67: TMenuItem;
    MenuItem69: TMenuItem;
    MenuItem70: TMenuItem;
    MenuItem72: TMenuItem;
    MenuItem76: TMenuItem;
    pmiUpSpeedLimit: TMenuItem;
    pmiDownSpeedLimit: TMenuItem;
    pmDownSpeeds: TPopupMenu;
    pmUpSpeeds: TPopupMenu;
    sepCon2: TMenuItem;
    MenuItem71: TMenuItem;
    sepCon1: TMenuItem;
    MenuItem73: TMenuItem;
    MenuItem74: TMenuItem;
    MenuItem75: TMenuItem;
    pmSepOpen2: TMenuItem;
    MenuItem42: TMenuItem;
    pmSepOpen1: TMenuItem;
    MenuItem44: TMenuItem;
    MenuItem45: TMenuItem;
    MenuItem46: TMenuItem;
    MenuItem47: TMenuItem;
    MenuItem48: TMenuItem;
    MenuItem49: TMenuItem;
    MenuItem50: TMenuItem;
    MenuItem51: TMenuItem;
    MenuItem52: TMenuItem;
    MenuItem53: TMenuItem;
    MenuItem54: TMenuItem;
    MenuItem55: TMenuItem;
    MenuItem56: TMenuItem;
    MenuItem58: TMenuItem;
    MenuItem59: TMenuItem;
    MenuItem60: TMenuItem;
    MenuItem61: TMenuItem;
    MenuItem62: TMenuItem;
    miPriority: TMenuItem;
    pmiPriority: TMenuItem;
    MenuItem57: TMenuItem;
    pbDownloaded: TPaintBox;
    pmTrackers: TPopupMenu;
    pmConnections: TPopupMenu;
    tabStats: TTabSheet;
    tabTrackers: TTabSheet;
    tbConnect: TToolButton;
    tbtAltSpeed: TToolButton;
    sepAltSpeed: TToolButton;
    sepQueue: TToolButton;
    tbQMoveUp: TToolButton;
    tbQMoveDown: TToolButton;
    ToolButton9: TToolButton;
    txConnErrorLabel: TLabel;
    panSearch: TPanel;
    panFilter: TPanel;
    panReconnectFrame: TShape;
    txDummy: TLabel;
    txReconnectSecs: TLabel;
    txConnError: TLabel;
    MenuItem38: TMenuItem;
    MenuItem39: TMenuItem;
    panReconnect: TPanel;
    txLastActive: TLabel;
    txLastActiveLabel: TLabel;
    txLabels: TLabel;
    txLabelsLabel: TLabel;
    txTracker: TLabel;
    txTrackerLabel: TLabel;
    txCompletedOn: TLabel;
    txCompletedOnLabel: TLabel;
    txAddedOn: TLabel;
    txAddedOnLabel: TLabel;
    MenuItem19: TMenuItem;
    MenuItem20: TMenuItem;
    MenuItem21: TMenuItem;
    MenuItem22: TMenuItem;
    MenuItem23: TMenuItem;
    MenuItem24: TMenuItem;
    miTSep1: TMenuItem;
    MenuItem26: TMenuItem;
    MenuItem27: TMenuItem;
    MenuItem28: TMenuItem;
    MenuItem29: TMenuItem;
    MenuItem30: TMenuItem;
    MenuItem31: TMenuItem;
    MenuItem32: TMenuItem;
    MenuItem33: TMenuItem;
    MenuItem36: TMenuItem;
    MenuItem37: TMenuItem;
    miAbout: TMenuItem;
    miHelp: TMenuItem;
    panTop: TPanel;
    pmTray: TPopupMenu;
    HSplitter: TSplitter;
    pmPeers: TPopupMenu;
    TrayIcon: TTrayIcon;
    txCreated: TLabel;
    txCreatedLabel: TLabel;
    txTorrentHeader: TPanel;
    txTorrentName: TLabel;
    txTorrentNameLabel: TLabel;
    txDownProgress: TLabel;
    txDownProgressLabel: TLabel;
    panProgress: TPanel;
    txMaxPeers: TLabel;
    txMaxPeersLabel: TLabel;
    txPeers: TLabel;
    txPeersLabel: TLabel;
    txSeeds: TLabel;
    txSeedsLabel: TLabel;
    txTrackerUpdate: TLabel;
    txRemaining: TLabel;
    txRemainingLabel: TLabel;
    txStatus: TLabel;
    txStatusLabel: TLabel;
    txRatio: TLabel;
    txRatioLabel: TLabel;
    txDownLimit: TLabel;
    txDownLimitLabel: TLabel;
    txTrackerUpdateLabel: TLabel;
    txTransferHeader: TPanel;
    txUpSpeed: TLabel;
    txUpLimit: TLabel;
    txUpSpeedLabel: TLabel;
    txDownSpeed: TLabel;
    txDownSpeedLabel: TLabel;
    txUploaded: TLabel;
    txUploadedLabel: TLabel;
    txDownloaded: TLabel;
    txDownloadedLabel: TLabel;
    txUpLimitLabel: TLabel;
    txWasted: TLabel;
    txWastedLabel: TLabel;
    miCopyLabel: TMenuItem;
    pmLabels: TPopupMenu;
    txError: TLabel;
    txErrorLabel: TLabel;
    MenuItem17: TMenuItem;
    MenuItem18: TMenuItem;
    miTools: TMenuItem;
    TickTimer: TTimer;
    MainToolBar: TToolBar;
    panTransfer: TPanel;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    tbStopTorrent: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    txComment: TLabel;
    txCommentLabel: TLabel;
    txHash: TLabel;
    txHashLabel: TLabel;
    panGeneralInfo: TPanel;
    lvFiles: TVarGrid;
    lvPeers: TVarGrid;
    MainMenu: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem13: TMenuItem;
    MenuItem14: TMenuItem;
    MenuItem15: TMenuItem;
    MenuItem16: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    miConnect: TMenuItem;
    miExit: TMenuItem;
    miTorrent: TMenuItem;
    OpenTorrentDlg: TOpenDialog;
    PageInfo: TPageControl;
    pmTorrents: TPopupMenu;
    pmFiles: TPopupMenu;
    sbGenInfo: TScrollBox;
    txPieces: TLabel;
    txPiecesLabel: TLabel;
    txTotalSize: TLabel;
    txTotalSizeLabel: TLabel;
    gTorrents: TVarGrid;
    gStats: TVarGrid;
    VSplitter: TSplitter;
    StatusBar: TStatusBar;
    tabPeers: TTabSheet;
    tabGeneral: TTabSheet;
    TorrentsListTimer: TTimer;
    tabFiles: TTabSheet;
    procedure acAddLinkExecute(Sender: TObject);
    procedure acAddTorrentExecute(Sender: TObject);
    procedure acAddTrackerExecute(Sender: TObject);
    procedure acAdvEditTrackersExecute(Sender: TObject);
    procedure acAltSpeedExecute(Sender: TObject);
    procedure acBigToolbarExecute(Sender: TObject);
    procedure acCheckNewVersionExecute(Sender: TObject);
    procedure acConnectExecute(Sender: TObject);
    procedure acConnOptionsExecute(Sender: TObject);
    procedure acCopyPathExecute(Sender: TObject);
    procedure acDelTrackerExecute(Sender: TObject);
    procedure acEditTrackerExecute(Sender: TObject);
    procedure acFilterPaneExecute(Sender: TObject);
    procedure acFolderGroupingExecute(Sender: TObject);
    procedure acForceStartTorrentExecute(Sender: TObject);
    procedure acHideAppExecute(Sender: TObject);
    procedure acInfoPaneExecute(Sender: TObject);
    procedure acLabelGroupingExecute(Sender: TObject);
    procedure acMenuShowExecute(Sender: TObject);
    procedure acMoveTorrentExecute(Sender: TObject);
    procedure acNewConnectionExecute(Sender: TObject);
    procedure acOpenContainingFolderExecute(Sender: TObject);
    procedure acOpenFileExecute(Sender: TObject);
    procedure acOptionsExecute(Sender: TObject);
    procedure acDisconnectExecute(Sender: TObject);
    procedure acExportExecute(Sender: TObject);
    procedure acImportExecute(Sender: TObject);
    procedure acExitExecute(Sender: TObject);
    procedure acDaemonOptionsExecute(Sender: TObject);
    procedure acQMoveBottomExecute(Sender: TObject);
    procedure acQMoveDownExecute(Sender: TObject);
    procedure acQMoveTopExecute(Sender: TObject);
    procedure acQMoveUpExecute(Sender: TObject);
    procedure acReannounceTorrentExecute(Sender: TObject);
    procedure acRemoveTorrentAndDataExecute(Sender: TObject);
    procedure acRemoveTorrentExecute(Sender: TObject);
    procedure acRenameExecute(Sender: TObject);
    procedure acResolveCountryExecute(Sender: TObject);
    procedure acResolveHostExecute(Sender: TObject);
    procedure acSelectAllExecute(Sender: TObject);
    procedure acSetHighPriorityExecute(Sender: TObject);
    procedure acSetLowPriorityExecute(Sender: TObject);
    procedure acSetNormalPriorityExecute(Sender: TObject);
    procedure acSetNotDownloadExecute(Sender: TObject);
    procedure acSetLabelsExecute(Sender: TObject);
    procedure acSetupColumnsExecute(Sender: TObject);
    procedure acShowAppExecute(Sender: TObject);
    procedure acShowCountryFlagExecute(Sender: TObject);
    procedure acStartAllTorrentsExecute(Sender: TObject);
    procedure acStartTorrentExecute(Sender: TObject);
    procedure acStatusBarExecute(Sender: TObject);
    procedure acStatusBarSizesExecute(Sender: TObject);
    procedure acStopAllTorrentsExecute(Sender: TObject);
    procedure acStopTorrentExecute(Sender: TObject);
    procedure gTorrentsMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure gTorrentsMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure LocalWatchTimerTimer(Sender: TObject);
    procedure lvFilesMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure MenuShowExecute(Sender: TObject);
    procedure acToolbarShowExecute(Sender: TObject);
    procedure acTorrentPropsExecute(Sender: TObject);
    procedure acTrackerGroupingExecute(Sender: TObject);
    procedure acUpdateBlocklistExecute(Sender: TObject);
    procedure acUpdateGeoIPExecute(Sender: TObject);
    procedure acVerifyTorrentExecute(Sender: TObject);
    procedure ApplicationPropertiesEndSession(Sender: TObject);
    procedure ApplicationPropertiesException(Sender: TObject; E: Exception);
    procedure ApplicationPropertiesIdle(Sender: TObject; var Done: Boolean);
    procedure ApplicationPropertiesMinimize(Sender: TObject);
    procedure ApplicationPropertiesRestore(Sender: TObject);
    procedure edSearchChange(Sender: TObject);
    procedure edSearchKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState );
    procedure FormActivate(Sender: TObject);
    procedure FormDropFiles(Sender: TObject; const FileNames: array of String);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormWindowStateChange(Sender: TObject);
    procedure gTorrentsCellAttributes(Sender: TVarGrid; ACol, ARow, ADataCol: integer; AState: TGridDrawState; var CellAttribs: TCellAttributes);
    procedure gTorrentsClick(Sender: TObject);
    procedure gTorrentsDblClick(Sender: TObject);
    procedure gTorrentsDrawCell(Sender: TVarGrid; ACol, ARow, ADataCol: integer; AState: TGridDrawState; const R: TRect; var ADefaultDrawing: boolean);
    procedure gTorrentsEditorHide(Sender: TObject);
    procedure gTorrentsEditorShow(Sender: TObject);
    procedure gTorrentsQuickSearch(Sender: TVarGrid; var SearchText: string; var ARow: integer);
    procedure gTorrentsResize(Sender: TObject);
    procedure gTorrentsSetEditText(Sender: TObject; ACol, ARow: Integer; const Value: string);
    procedure gTorrentsSortColumn(Sender: TVarGrid; var ASortCol: integer);
    procedure HSplitterChangeBounds(Sender: TObject);
    procedure lvFilesDblClick(Sender: TObject);
    procedure lvFilesEditorHide(Sender: TObject);
    procedure lvFilesEditorShow(Sender: TObject);
    procedure lvFilesSetEditText(Sender: TObject; ACol, ARow: Integer; const Value: string);
    procedure lvFilterCellAttributes(Sender: TVarGrid; ACol, ARow, ADataCol: integer; AState: TGridDrawState; var CellAttribs: TCellAttributes);
    procedure lvFilterClick(Sender: TObject);
    procedure lvFilterDrawCell(Sender: TVarGrid; ACol, ARow, ADataCol: integer; AState: TGridDrawState; const R: TRect; var ADefaultDrawing: boolean);
    procedure lvPeersCellAttributes(Sender: TVarGrid; ACol, ARow, ADataCol: integer; AState: TGridDrawState; var CellAttribs: TCellAttributes);
    procedure lvTrackersCellAttributes(Sender: TVarGrid; ACol, ARow, ADataCol: integer; AState: TGridDrawState; var CellAttribs: TCellAttributes);
    procedure lvTrackersDblClick(Sender: TObject);
    procedure lvTrackersKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure goDevelopmentSiteClick(Sender: TObject);
    procedure MainToolBarContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
    procedure MenuItem101Click(Sender: TObject);
    procedure miHomePageClick(Sender: TObject);
    procedure PageInfoResize(Sender: TObject);
    procedure panReconnectResize(Sender: TObject);
    procedure pbDownloadedPaint(Sender: TObject);
    procedure StatusBarMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure TickTimerTimer(Sender: TObject);
    procedure FilterTimerTimer(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure lvFilterResize(Sender: TObject);
    procedure miAboutClick(Sender: TObject);
    procedure miCopyLabelClick(Sender: TObject);
    procedure PageInfoChange(Sender: TObject);
    procedure tbSearchCancelClick(Sender: TObject);
    procedure TorrentsListTimerTimer(Sender: TObject);
    procedure pmFilesPopup(Sender: TObject);
    procedure pmTorrentsPopup(Sender: TObject);
    procedure TrayIconDblClick(Sender: TObject);
    procedure VSplitterChangeBounds(Sender: TObject);
    function CorrectPath (path: string): string; // PETROV
  private
    FStarted: boolean;
    FTorrents: TVarList;
    FFiles: TVarList;
    FTrackers: TStringList;
    FResolver: TIpResolver;
    FUnZip: TUnZipper;
    FReconnectWaitStart: TDateTime;
    FReconnectTimeOut: integer;
    FTorrentProgress: TBitmap;
    FLastPieces: string;
    FLastPieceCount: integer;
    FLastDone: double;
    FPathMap: TStringList;
    FLastFilerIndex: integer;
    FFilterChanged: boolean;
    FCurDownSpeedLimit: integer;
    FCurUpSpeedLimit: integer;
    FFlagsPath: string;
    FAddingTorrent: integer;
    FPendingTorrents: TStringList;
    FLinksFromClipboard: boolean;
    FLastClipboardLink: string;
    FLinuxOpenDoc: integer; // no del!
    FFromNow: boolean;
    FWatchLocalFolder: string;
    FWatchDestinationFolder: string;
    FWatchDownloading: boolean;
    FRow: integer;
    FCol: integer;
{$ifdef windows}
    FFileManagerDefault: string;
    FFileManagerDefaultParam: string;
    FGlobalHotkey: string;
    fGlobalHotkeyMod: string;
    FUserDefinedMenuEx: string;
    FUserDefinedMenuParam: string;
{$endif windows}
{$ifdef LCLcarbon}
    FFormActive: boolean;
{$endif LCLcarbon}
    FSlowResponse: TProgressImage;
    FDetailsWait: TProgressImage;
    FDetailsWaitStart: TDateTime;
    FMainFormShown: boolean;
    FFilesTree: TFilesTree;
    FFilesCapt: string;
    FCalcAvg: boolean;
    FPasswords: TStringList;
    FAppProps:TApplicationProperties;

    procedure UpdateUI;
    procedure UpdateUIRpcVersion(RpcVersion: integer);
    function DoConnect: boolean;
    procedure DoCreateOutZipStream(Sender: TObject; var AStream: TStream; AItem: TFullZipFileEntry);
    procedure DoDisconnect;
    procedure DoOpenFlagsZip(Sender: TObject; var AStream: TStream);
    procedure TorrentProps(PageNo: integer);
    procedure ShowConnOptions(NewConnection: boolean);
    procedure SaveColumns(LV: TVarGrid; const AName: string; FullInfo: boolean = True);
    procedure LoadColumns(LV: TVarGrid; const AName: string; FullInfo: boolean = True);
    function GetTorrentError(t: TJSONObject; Status: integer): string;
    function SecondsToString(j: integer): string;
    function DoAddTorrent(const FileName: Utf8String): boolean;
    procedure UpdateTray;
    procedure HideApp;
    procedure ShowApp;
    procedure DownloadFinished(const TorrentName: string);
    function GetFlagImage(const CountryCode: string): integer;
    procedure BeforeCloseApp;
    function GetGeoIpDatabase: string;
    function GetFlagsArchive: string;
    function DownloadGeoIpDatabase(AUpdate: boolean): boolean;
    procedure TorrentColumnsChanged;
    function EtaToString(ETA: integer): string;
    function GetTorrentStatus(TorrentIdx: integer): string;
    function GetSeedsText(Seeds, SeedsTotal: integer): string;
    function GetPeersText(Peers, PeersTotal, Leechers: integer): string;
    function RatioToString(Ratio: double): string;
    function TorrentDateTimeToString(d: Int64; FromNow:Boolean = false): string;
    procedure DoRefresh(All: boolean = False);
    function GetFilesCommonPath(files: TJSONArray): string;
    procedure InternalRemoveTorrent(const Msg, MsgMulti: string; RemoveLocalData: boolean);
    function IncludeProperTrailingPathDelimiter(const s: string): string;
    procedure UrlLabelClick(Sender: TObject);
    procedure CenterReconnectWindow;
    procedure ProcessPieces(const Pieces: string; PieceCount: integer; const Done: double);
    function ExecRemoteFile(const FileName: string; SelectFile: boolean; Userdef: boolean= false): boolean;
    function GetSelectedTorrents: variant;
    function GetDisplayedTorrents: variant;
    procedure FillDownloadDirs(CB: TComboBox; const CurFolderParam: string);
    procedure SaveDownloadDirs(CB: TComboBox; const CurFolderParam: string);
    procedure DeleteDirs(CB: TComboBox; maxdel : Integer);
    procedure SetRefreshInterval;
    procedure AddTracker(EditMode: boolean);
    procedure UpdateConnections;
    procedure DoConnectToHost(Sender: TObject);
    procedure FillSpeedsMenu;
    procedure DoSetDownloadSpeed(Sender: TObject);
    procedure DoSetUploadSpeed(Sender: TObject);
    procedure SetSpeedLimit(const Dir: string; Speed: integer);
    function FixSeparators(const p: string): string;
    function MapRemoteToLocal(const RemotePath: string): string;
    procedure CheckAddTorrents;
    procedure CheckClipboardLink;
    procedure CenterDetailsWait;
    procedure ReadLocalFolderWatch;
    function GetPageInfoType(pg: TTabSheet): TAdvInfoType;
    procedure DetailsUpdated;
    function RenameTorrent(TorrentId: integer; const OldPath, NewName: string): boolean;
    procedure FilesTreeStateChanged(Sender: TObject);
    function SelectTorrent(TorrentId, TimeOut: integer): integer;
    procedure OpenCurrentTorrent(OpenFolderOnly: boolean; UserDef: boolean=false);
  public
    FCurConn: string;
    FCreateFolder: boolean;
	FGCSSID: string;
    FGCSSIDAPIKey: string;
    procedure FillTorrentsList(list: TJSONArray);
    procedure FillPeersList(list: TJSONArray);
    procedure FillFilesList(ATorrentId: integer; list, priorities, wanted: TJSONArray; const DownloadDir: WideString);
    procedure FillGeneralInfo(t: TJSONObject);
    procedure FillTrackersList(TrackersData: TJSONObject);
    procedure FillSessionInfo(s: TJSONObject);
    procedure FillStatistics(s: TJSONObject);
    procedure CheckStatus(Fatal: boolean = True);
    function TorrentAction(const TorrentIds: variant; const AAction: string; args: TJSONObject = nil): boolean;
    function SetFilePriority(TorrentId: integer; const Files: array of integer; const APriority: string): boolean;
    function SetCurrentFilePriority(const APriority: string): boolean;
    procedure SetTorrentPriority(APriority: integer);
    procedure ClearDetailsInfo(Skip: TAdvInfoType = aiNone);
    function SelectRemoteFolder(const CurFolder, DialogTitle: string): string;
    procedure ConnectionSettingsChanged(const ActiveConnection: string; ForceReconnect: boolean);
    procedure StatusBarSizes;
    function PubMapRemoteToLocal(const RemotePath: string): string;
private
    procedure _onException(Sender: TObject; E: Exception);
end;

function ExcludeInvalidChar (path: string): string; // PETROV
function GetBiDi: TBiDiMode;
function CheckAppParams: boolean;
procedure LoadTranslation;
function GetHumanSize(sz: double; RoundTo: integer = 0; const EmptyStr: string = '-'): string;
function PriorityToStr(p: integer; var ImageIndex: integer): string;
procedure DrawProgressCell(Sender: TVarGrid; ACol, ARow, ADataCol: integer; AState: TGridDrawState; const ACellRect: TRect);

var
  MainForm: TMainForm;
  RpcObj: TRpc;
  FTranslationFileName: string;
  FTranslationLanguage: string;
  FAlterColor: TColor;
  IsUnity: boolean;
  Ini: TIniFileUtf8;
  FHomeDir: string;
  {$ifdef windows}
  PrevWndProc: windows.WNDPROC;
  HotKeyID: Integer;
  {$endif windows}

const
  // Torrents list
  idxName = 0;
  idxSize = 1;
  idxDone = 2;
  idxStatus = 3;
  idxSeeds = 4;
  idxPeers = 5;
  idxDownSpeed = 6;
  idxUpSpeed = 7;
  idxETA = 8;
  idxRatio = 9;
  idxDownloaded = 10;
  idxUploaded = 11;
  idxTracker = 12;
  idxTrackerStatus = 13;
  idxAddedOn = 14;
  idxCompletedOn = 15;
  idxLastActive = 16;
  idxPath = 17;
  idxPriority = 18;
  idxSizeToDowload = 19;
  idxTorrentId = 20;
  idxQueuePos = 21;
  idxSeedingTime = 22;
  idxSizeLeft = 23;
  idxPrivate = 24;
  idxLabels = 25;

  idxTag = -1;
  idxSeedsTotal = -2;
  idxLeechersTotal = -3;
  idxStateImg = -4;
  idxDeleted = -5;
  idxDownSpeedHistory = -6;
  idxUpSpeedHistory = -7;
  TorrentsExtraColumns = 7;

  // Peers list
  idxPeerHost = 0;
  idxPeerPort = 1;
  idxPeerCountry = 2;
  idxPeerClient = 3;
  idxPeerFlags = 4;
  idxPeerDone = 5;
  idxPeerUpSpeed = 6;
  idxPeerDownSpeed = 7;
  idxPeerTag = -1;
  idxPeerIP = -2;
  idxPeerCountryImage = -3;
  PeersExtraColumns = 3;

  // Trackers list
  idxTrackersListName = 0;
  idxTrackersListStatus = 1;
  idxTrackersListUpdateIn = 2;
  idxTrackersListSeeds = 3;
  idxTrackerTag = -1;
  idxTrackerID = -2;
  TrackersExtraColumns = 2;

  // Filter idices
  fltAll      = 0;
  fltDown     = 1;
  fltDone     = 2;
  fltActive   = 3;
  fltInactive = 4;
  fltStopped  = 5;
  fltError  = 6;
  fltWaiting = 7;

  // Status images
  imgDown      = 9;
  imgSeed      = 10;
  imgDownError = 11;
  imgSeedError = 12;
  imgError     = 13;
  imgDone      = 14;
  imgStopped   = 29;
  imgDownQueue = 16;
  imgSeedQueue = 17;
  imgAll       = 19;
  imgActive    = 20;
  imgInactive  = 15;
  imgWaiting   = 42;

  StatusFiltersCount = 8;

  TorrentFieldsMap: array[idxName..idxLabels] of string =
    ('', 'totalSize', '', 'status', 'peersSendingToUs,seeders',
    'peersGettingFromUs,leechers', '', '', 'eta', 'uploadRatio',
    'downloadedEver', 'uploadedEver', '', '', 'addedDate', 'doneDate', 'activityDate', '', 'bandwidthPriority',
    '', '', 'queuePosition', 'secondsSeeding', 'leftUntilDone', 'isPrivate', 'labels');

  FinishedQueue = 1000000;

  TR_PRI_SKIP   = -1000;  // psedudo priority
  TR_PRI_LOW    = -1;
  TR_PRI_NORMAL =  0;
  TR_PRI_HIGH   =  1;

implementation

uses
{$ifdef linux}
  process, dynlibs,
{$endif linux}
{$ifdef darwin}
  urllistenerosx,
{$endif darwin}
  synacode, ConnOptions, clipbrd, DateUtils, TorrProps, DaemonOptions, About,
  ToolWin, download, ColSetup, AddLink, MoveTorrent, ssl_openssl_lib, AddTracker, lcltype,
  Options, ButtonPanel, BEncode, synautil, Math;

  {TMyHashMap}
  function TMyHashMap.DefaultHashKey(const Key: Integer): Integer;
  begin
    Result := Key;
    if Odd(Result) then
      Result := Result * 3;
    end;

  function TMyHashMap.DefaultKeysEqual(const A, B: Integer): Boolean;
  begin
    Result := A = B;
  end;

  function TMyHashMap.DefaultKeyToString(const Key: Integer): String;
  begin
    WriteStr(Result, Key);
  end;

  function TMyHashMap.DefaultItemToString(const Item: Integer): String;
  begin
    WriteStr(Result, Item);
  end;

const
  TR_STATUS_CHECK_WAIT_1   = ( 1 shl 0 ); // Waiting in queue to check files
  TR_STATUS_CHECK_1        = ( 1 shl 1 ); // Checking files
  TR_STATUS_DOWNLOAD_1     = ( 1 shl 2 ); // Downloading
  TR_STATUS_SEED_1         = ( 1 shl 3 ); // Seeding
  TR_STATUS_STOPPED_1      = ( 1 shl 4 ); // Torrent is stopped

  TR_STATUS_STOPPED_2       = 0;     // Torrent is stopped
  TR_STATUS_CHECK_WAIT_2    = 1;     // Queued to check files
  TR_STATUS_CHECK_2         = 2;     // Checking files
  TR_STATUS_DOWNLOAD_WAIT_2 = 3;     // Queued to download
  TR_STATUS_DOWNLOAD_2      = 4;     // Downloading
  TR_STATUS_SEED_WAIT_2     = 5;     // Queued to seed
  TR_STATUS_SEED_2          = 6;     // Seeding

  TR_STATUS_FINISHED        = $100; // Torrent is finished (pseudo status)

  TR_SPEEDLIMIT_GLOBAL    = 0;    // only follow the overall speed limit
  TR_SPEEDLIMIT_SINGLE    = 1;    // only follow the per-torrent limit
  TR_SPEEDLIMIT_UNLIMITED = 2;    // no limits at all

  SpeedHistorySize = 20;

const
  SizeNames: array[1..5] of string = (sByte, sKByte, sMByte, sGByte, sTByte);

var
  TR_STATUS_STOPPED, TR_STATUS_CHECK_WAIT, TR_STATUS_CHECK, TR_STATUS_DOWNLOAD_WAIT, TR_STATUS_DOWNLOAD, TR_STATUS_SEED_WAIT, TR_STATUS_SEED: integer;


  {$ifdef windows}
function WndCallback(Ahwnd: HWND; uMsg: UINT; wParam: WParam; lParam: LParam):LRESULT; stdcall;
begin
  if (uMsg=WM_HOTKEY) and (WParam=HotKeyID) then
    begin
      if (MainForm.Visible = false) or (MainForm.WindowState = wsMinimized) then
          MainForm.ShowApp
          else
          MainForm.HideApp;
    end;
  result:=CallWindowProc(PrevWndProc,Ahwnd, uMsg, WParam, LParam);
end;

  {$endif windows}

function IsHash(Hash: String): boolean;
var i: integer;
begin
      Result := false;
      if Hash = '' then exit;
      if Length(Hash) = 32 then   // possible base32 encoded hash
                      try
                        Hash:=StrToHex(Base32Decode(UpperCase(Hash)));
                      except
                        exit;
                      end;
    if Length(Hash) <> 40 then exit;
    Result := true;
    for i := 1 to 40 do if not (Hash[i] in ['a' .. 'f', 'A'..'F', '0'..'9']) then Result := false;
end;

procedure TMainForm.ReadLocalFolderWatch;
var
  sr: TSearchRec;
begin
    if FPendingTorrents.Count = 0 then
      begin
            if FindFirstUTF8(FWatchLocalFolder+'*.torrent',faAnyFile,sr)=0 then
              repeat
                    FPendingTorrents.Add(FWatchLocalFolder+sr.Name);
              until FindNextUTF8(sr)<>0;
            FindCloseUTF8(sr);
      end;
end;

function GetHumanSize(sz: double; RoundTo: integer; const EmptyStr: string): string;
var
  i: integer;
begin
  if sz < 0 then begin
    Result:=EmptyStr;
    exit;
  end;
  i:=Low(SizeNames);
  if RoundTo > 0 then begin
    Inc(i);
    sz:=sz/1024;
  end;
  while i <= High(SizeNames) do begin
    if sz < 1024 then
      break;
    sz:=sz/1024;
    Inc(i);
  end;
  if (RoundTo = 0) and (i > 3) then
    RoundTo:=i - 2;
  Result:=Format('%.' + IntToStr(RoundTo) + 'f %s', [sz, SizeNames[i]]);
end;

function AddToChannel(Clr: TColor; Value: integer; Position: byte): TColor;
var i: integer;

begin
    i:=(Clr shr (Position*8)) and $FF;
    i:=i + Value;
    if i < 0 then i:=0;
    if i > $FF then i:=$FF;
    Result:=Clr and (not (Cardinal($FF) shl (Position*8))) or (Cardinal(i) shl (Position*8));
end;

function AddToColor(Color: TColor; R, G, B: integer): TColor;
begin
    Result:=ColorToRGB(Color);
    Result:=AddToChannel(Result, R, 0);
    Result:=AddToChannel(Result, G, 1);
    Result:=AddToChannel(Result, B, 2);
end;

function GetLikeColor(Color: TColor; Delta: integer): TColor;
var i, j: integer;

begin
    Result:=ColorToRGB(Color);
    j:=Result and $FF;               //red
    i:=(Result shr 8) and $FF;       // green
    if i > j then
      j:=i;
    i:=((Result shr 16) and $FF) shr 1;      // blue
    if i > j then
      j:=i;
    if j < $80 then
      i:=(($80 - j) div $20 + 1)*Delta
    else
      i:=Delta;
    if (i + j > 255) or (i + j < 0) then
      i:=-Delta;

    Result:=AddToColor(Result, i, i, i);
end;

function LocateFile(const FileName: string; const Paths: array of string): string;
var
  i: integer;
begin
  for i:=Low(Paths) to High(Paths) do begin
    Result:=IncludeTrailingPathDelimiter(Paths[i]) + FileName;
    if FileExistsUTF8(Result) then
      exit;
  end;
  Result:='';
end;

procedure OnTranslate(Sender: TResTranslator; const ResourceName: AnsiString; var Accept: boolean);
const
  IgnoreUnits: array[0..12] of string =
      ('fpjson','jsonparser','jsonscanner','lclstrconsts','math',
      'rtlconsts','sysconst','variants','zbase','zipper','zstream',
      'xmlcfg', 'registry');

  IgnoreControls: array[0..3] of string =
    ('AboutForm.txAuthor', 'MainForm.miLn', 'ConnOptionsForm.cbUseSocks5', 'ConnOptionsForm.tabConnection');

var
  i: integer;
begin
  Accept := not AnsiMatchText(Copy2Symb(ResourceName, '.'), IgnoreUnits)
            or AnsiStartsText('lclstrconsts.rsMb', ResourceName)  //<-- dialog buttons
            or AnsiStartsText('lclstrconsts.rsMt', ResourceName); //<-- dialog message
  if Accept then
    for i:=Low(IgnoreControls) to High(IgnoreControls) do
      if AnsiStartsText(IgnoreControls[i], ResourceName) then begin
        Accept:=False;
        exit;
      end;
  if Accept and (Copy(ResourceName, Length(ResourceName) - 8, MaxInt) = '.Category') then
    Accept:=False;
end;

var
  FIPCFileName: string;
  FRunFileName: string;

function IsProtocolSupported(const url: string): boolean;
const
  Protocols: array [1..3] of string =
    ('http:', 'https:', 'magnet:');
var
  i: integer;
  s: string;
begin
  s:=AnsiLowerCase(url);
  for i:=Low(Protocols) to High(Protocols) do
    if Copy(s, 1, Length(Protocols[i])) = Protocols[i] then begin
      Result:=True;
      exit;
    end;
  Result:=False;
end;

procedure AddTorrentFile(const FileName: string);
var
  h: System.THandle;
  t: TDateTime;
  s: string;
begin
  if not IsProtocolSupported(FileName) and not FileExistsUTF8(FileName) then
    exit;
  t:=Now;
  repeat
    if FileExistsUTF8(FIPCFileName) then
      h:=FileOpenUTF8(FIPCFileName, fmOpenWrite or fmShareDenyRead or fmShareDenyWrite)
    else
      h:=FileCreateUTF8(FIPCFileName);
    if h <> System.THandle(-1) then begin
      s:=FileName + LineEnding;
      FileSeek(h, 0, soFromEnd);
      FileWrite(h, s[1], Length(s));
      FileClose(h);
      break;
    end;
    Sleep(20);
  until Now - t >= 3/SecsPerDay;
end;

procedure LoadTranslation;
begin
  if Ini.ReadBool('Translation', 'TranslateForm', True) = False then
    FTranslationLanguage := 'English'
  else begin
  FTranslationFileName := Ini.ReadString('Interface', 'TranslationFile', '');
  if FTranslationFileName <> '-' then
    if (FTranslationFileName = '') or not IsTranslationFileValid(DefaultLangDir + FTranslationFileName) then
      FTranslationLanguage := LoadDefaultTranslationFile(@OnTranslate)
    else
      FTranslationLanguage := LoadTranslationFile(DefaultLangDir + FTranslationFileName, @OnTranslate);
  if FTranslationLanguage = '' then
    FTranslationLanguage := 'English'
end;
end;

function CheckAppParams: boolean;
var
  i: integer;
  s: string;
  h: System.THandle;
  pid: SizeUInt;
{$ifdef linux}
  proc: TProcess;
  sr: TSearchRec;
  hLib: TLibHandle;
{$endif linux}
begin
  Application.Title:=AppName;
{$ifdef linux}
  IsUnity:=CompareText(GetEnvironmentVariable('XDG_CURRENT_DESKTOP'), 'unity') = 0;
  if GetEnvironmentVariable('LIBOVERLAY_SCROLLBAR') <> '0' then begin
    i:=FindFirstUTF8('/usr/lib/liboverlay-scrollbar*', faAnyFile, sr);
    FindClose(sr);
    hLib:=LoadLibrary('liboverlay-scrollbar.so');
    if hLib <> 0 then
      FreeLibrary(hLib);
    if (i = 0) or (hLib <> 0) then begin
      // Turn off overlay scrollbars, since they are not supported yet.
      // Restart the app with the LIBOVERLAY_SCROLLBAR=0 env var.
      proc:=TProcess.Create(nil);
      try
        proc.Executable:=ParamStrUTF8(0);
        for i:=1 to ParamCount do
      proc.Parameters.Add(ParamStrUTF8(i));
        for i:=0 to GetEnvironmentVariableCount - 1 do
          proc.Environment.Add(GetEnvironmentString(i));
        proc.Environment.Values['LIBOVERLAY_SCROLLBAR']:='0';
        proc.Execute;
      finally
        proc.Free;
      end;
      Result:=False;
      exit;
    end;
  end;
{$endif linux}
  FHomeDir:=GetCmdSwitchValue('home');
  if FHomeDir = '' then begin
    if FileExistsUTF8(ChangeFileExt(ParamStrUTF8(0), '.ini')) then
      FHomeDir:=ExtractFilePath(ParamStrUTF8(0)) // Portable mode
    else
      FHomeDir:=IncludeTrailingPathDelimiter(GetAppConfigDirUTF8(False));
  end
  else
    FHomeDir:=IncludeTrailingPathDelimiter(FHomeDir);
  ForceDirectoriesUTF8(FHomeDir);
  FIPCFileName:=FHomeDir + 'ipc.txt';
  FRunFileName:=FHomeDir + 'run';

  Ini:=TIniFileUtf8.Create(FHomeDir+ChangeFileExt(ExtractFileName(ParamStrUTF8(0)), '.ini'));
  Ini.CacheUpdates:=True;

  // Check for outdated IPC file
  if FileExistsUTF8(FIPCFileName) then begin
    h:=FileOpenUTF8(FIPCFileName, fmOpenRead or fmShareDenyNone);
    if h <> INVALID_HANDLE_VALUE then begin
      i:=FileGetDate(h);
      FileClose(h);
      if (i > 0) and (Abs(Now - FileDateToDateTime(i)) > 1/MinsPerDay) then
        DeleteFileUTF8(FIPCFileName);
    end;
  end;

  for i:=1 to ParamCount do begin
    s:=ParamStrUTF8(i);
    if IsProtocolSupported(s) or FileExistsUTF8(s) then
      AddTorrentFile(s);
  end;

  if FileExistsUTF8(FRunFileName) then begin
    // Another process is running
    h:=FileOpenUTF8(FRunFileName, fmOpenRead or fmShareDenyNone);
    if FileRead(h, pid, SizeOf(pid)) = SizeOf(pid) then begin
{$ifdef mswindows}
      AllowSetForegroundWindow(pid);
{$endif mswindows}
    end;
    FileClose(h);

    if not FileExistsUTF8(FIPCFileName) then
      FileClose(FileCreateUTF8(FIPCFileName));
    for i:=1 to 50 do
      if not FileExistsUTF8(FIPCFileName) then begin
        // The running process works normally. Exit application.
        Result:=False;
        exit;
      end
      else
        Sleep(200);
    // The running process is not responding
    DeleteFileUTF8(FRunFileName);
    // Delete IPC file if it is empty
    h:=FileOpenUTF8(FIPCFileName, fmOpenRead or fmShareDenyNone);
    i:=FileSeek(h, 0, soFromEnd);
    FileClose(h);
    if i = 0 then
      DeleteFileUTF8(FIPCFileName);
  end;

  // Create a new run file
  h:=FileCreateUTF8(FRunFileName);
  pid:=GetProcessID;
  FileWrite(h, pid, SizeOf(pid));
  FileClose(h);

  LoadTranslation;

  GetBiDi;

  SizeNames[1]:=sByte;
  SizeNames[2]:=sKByte;
  SizeNames[3]:=sMByte;
  SizeNames[4]:=sGByte;
  SizeNames[5]:=sTByte;

  IntfScale:=Ini.ReadInteger('Interface', 'Scaling', 100);

  Result:=True;
end;

function PriorityToStr(p: integer; var ImageIndex: integer): string;
begin
  case p of
    TR_PRI_SKIP:   begin Result:=sSkip; ImageIndex:=23; end;
    TR_PRI_LOW:    begin Result:=sLow; ImageIndex:=24; end;
    TR_PRI_NORMAL: begin Result:=sNormal; ImageIndex:=25; end;
    TR_PRI_HIGH:   begin Result:=sHigh; ImageIndex:=26; end;
    else           Result:='???';
  end;
end;

procedure DrawProgressCell(Sender: TVarGrid; ACol, ARow, ADataCol: integer; AState: TGridDrawState; const ACellRect: TRect);
var
  R, RR: TRect;
  i, j, h: integer;
  s: string;
  cl: TColor;
  Progress: double;
  sz: TSize;
  ts: TTextStyle;
begin
  Progress:=double(Sender.Items[ADataCol, ARow]);
  with Sender.Canvas do begin
    R:=ACellRect;
    FrameRect(R);
    s:=Format('%.1f%%', [Progress]);
    sz:=TextExtent(s);
    InflateRect(R, -1, -1);
    Pen.Color:=clBtnFace;
    Rectangle(R);
    InflateRect(R, -1, -1);

    i:=R.Left + Round(Progress*(R.Right - R.Left)/100.0);
    j:=(R.Top + R.Bottom) div 2;
    h:=(R.Top + R.Bottom - sz.cy) div 2;
    cl:=GetLikeColor(clHighlight, 70);
    GradientFill(Rect(R.Left, R.Top, i, j), cl, clHighlight, gdVertical);
    GradientFill(Rect(R.Left, j, i, R.Bottom), clHighlight, cl, gdVertical);

    ts:=TextStyle;
    ts.Layout:=tlTop;
    ts.Alignment:=taLeftJustify;
    ts.Wordbreak:=False;
    TextStyle:=ts;
    j:=(R.Left + R.Right - sz.cx) div 2;
    if i > R.Left then begin
      RR:=Rect(R.Left, R.Top, i, R.Bottom);
      Font.Color:=clHighlightText;
      TextRect(RR, j, h, s);
    end;
    if i < R.Right then begin
      RR:=Rect(i, R.Top, R.Right, R.Bottom);
      Brush.Color:=Sender.Color;
      FillRect(RR);
      Font.Color:=clWindowText;
      TextRect(RR, j, h, s);
    end;
  end;
end;

{ TProgressImage }

procedure TProgressImage.SetImages(const AValue: TImageList);
begin
  if FImages=AValue then exit;
  FImages:=AValue;
  Width:=FImages.Width;
  Height:=FImages.Height;
end;

procedure TProgressImage.SetStartIndex(const AValue: integer);
begin
  if FStartIndex=AValue then exit;
  FStartIndex:=AValue;
  UpdateIndex;
end;

procedure TProgressImage.UpdateIndex;
begin
  if (FImageIndex < FStartIndex) or (FImageIndex > FEndIndex) then
    FImageIndex:=FStartIndex;
  Invalidate;
end;

procedure TProgressImage.DoTimer(Sender: TObject);
begin
  ImageIndex:=ImageIndex + 1;
end;

procedure TProgressImage.SetImageIndex(const AValue: integer);
begin
  if FImageIndex=AValue then exit;
  FImageIndex:=AValue;
  UpdateIndex;
end;

procedure TProgressImage.SetEndIndex(const AValue: integer);
begin
  if FEndIndex=AValue then exit;
  FEndIndex:=AValue;
  UpdateIndex;
end;

function TProgressImage.GetFrameDelay: integer;
begin
  Result:=FTimer.Interval;
end;

procedure TProgressImage.SetBorderColor(const AValue: TColor);
begin
  if FBorderColor=AValue then exit;
  FBorderColor:=AValue;
end;

procedure TProgressImage.SetFrameDelay(const AValue: integer);
begin
  FTimer.Interval:=AValue;
end;

procedure TProgressImage.Paint;
begin
  if FBmp = nil then begin
    FBmp:=TBitmap.Create;
    FBmp.Width:=Width;
    FBmp.Height:=Height;
  end;
  with FBmp.Canvas do begin
    Brush.Color:=clBtnFace;
    if FBorderColor <> clNone then begin
      Pen.Color:=FBorderColor;
      Rectangle(0, 0, FBmp.Width, FBmp.Height);
    end
    else
      FillRect(0, 0, FBmp.Width, FBmp.Height);
    if FImages <> nil then
      FImages.Draw(FBmp.Canvas, (Self.Width - FImages.Width) div 2, (Self.Height - FImages.Height) div 2, ImageIndex);
  end;
  Canvas.Draw(0, 0, FBmp);
end;

procedure TProgressImage.VisibleChanged;
begin
  inherited VisibleChanged;
  if Visible then begin
    ImageIndex:=StartIndex;
    FTimer.Enabled:=True;
  end
  else
    FTimer.Enabled:=False;
end;

constructor TProgressImage.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FTimer:=TTimer.Create(Self);
  FTimer.Enabled:=False;
  FTimer.Interval:=100;
  FTimer.OnTimer:=@DoTimer;
  FBorderColor:=clNone;
  Visible:=False;
end;

destructor TProgressImage.Destroy;
begin
  FBmp.Free;
  inherited Destroy;
end;

{ TMainForm }

procedure TMainForm.FormCreate(Sender: TObject);
var
  ws: TWindowState;
  i, j: integer;
  R: TRect;
  SL: TStringList;
  MI, MI2: TMenuItem;
  Ico: TIcon;
  LargeIco, SmallIco : hIcon;
  MenuCaption: String;
{$ifdef darwin}
  s: string;
  pic: TPicture;
{$endif darwin}
begin
{$ifdef darwin}
  // Load better icon if possible
  s:=ExtractFilePath(ParamStrUTF8(0)) + '..' + DirectorySeparator + 'Resources'
    + DirectorySeparator + ChangeFileExt(ExtractFileName(ParamStrUTF8(0)), '.icns');
  if FileExistsUTF8(s) then begin
    pic:=TPicture.Create;
    try
      pic.LoadFromFile(s);
      try
        Application.Icon.Assign(pic.Graphic);
      except
      end;
    finally
      pic.Free;
    end;
  end;

  RegisterURLHandler(@AddTorrentFile);
{$endif darwin}


  {$if FPC_FULlVERSION>=30101}
  AllowReuseOfLineInfoData:=false;
  {$endif}
  FAppProps := TApplicationProperties.Create(Self);
  FAppProps.OnException := @_onException;
  FAppProps.CaptureExceptions := True;


  Application.Title:=AppName + ' v' + AppVersion;
  Caption:=Application.Title;
  txTransferHeader.Font.Size:=Font.Size + 2;
  txTorrentHeader.Font.Size:=txTransferHeader.Font.Size;
  TrayIcon.Icon.Assign(Application.Icon);
  RpcObj:=TRpc.Create;
  FTorrents:=TVarList.Create(gTorrents.Columns.Count, 0);
  FTorrents.ExtraColumns:=TorrentsExtraColumns;
  gTorrents.Items.ExtraColumns:=TorrentsExtraColumns;
  lvFiles.Items.ExtraColumns:=FilesExtraColumns;
  FFiles:=lvFiles.Items;
  FFilesTree:=TFilesTree.Create(lvFiles);
  FFilesTree.Checkboxes:=True;
  FFilesTree.OnStateChange:=@FilesTreeStateChanged;
  lvPeers.Items.ExtraColumns:=PeersExtraColumns;
  lvTrackers.Items.ExtraColumns:=TrackersExtraColumns;
  FTrackers:=TStringList.Create;
  FTrackers.Sorted:=True;
  FReconnectTimeOut:=-1;
  FAlterColor:=GetLikeColor(gTorrents.Color, -$10);
  lvFilter.Items.ExtraColumns:=2;
  gTorrents.AlternateColor:=FAlterColor;
  lvPeers.AlternateColor:=FAlterColor;
  lvTrackers.AlternateColor:=FAlterColor;
  gStats.AlternateColor:=FAlterColor;
  FPendingTorrents:=TStringList.Create;
  FFilesCapt:=tabFiles.Caption;
  FPasswords:=TStringList.Create;

  FSlowResponse:=TProgressImage.Create(MainToolBar);
  with FSlowResponse do begin
    Align:=alRight;
    Images:=ImageList16;
    StartIndex:=30;
    EndIndex:=37;
    Width:=ScaleInt(24);
    Left:=MainToolBar.ClientWidth;
    Parent:=MainToolBar;
  end;

  FDetailsWait:=TProgressImage.Create(panDetailsWait);
  with FDetailsWait do begin
    Images:=ImageList16;
    StartIndex:=FSlowResponse.StartIndex;
    EndIndex:=FSlowResponse.EndIndex;
    Width:=Images.Width*2;
    Height:=Width;
    BorderColor:=clBtnShadow;
    panDetailsWait.Width:=Width;
    panDetailsWait.Height:=Height;
    Parent:=panDetailsWait;
  end;

  DoDisconnect;
  PageInfo.ActivePageIndex:=0;
  PageInfoChange(nil);
{$ifdef LCLgtk2}
  with MainToolBar do begin
    EdgeBorders:=[ebLeft, ebTop, ebRight, ebBottom];
    EdgeInner:=esNone;
    EdgeOuter:=esRaised;
    Flat:=True;
  end;
  i:=acAltSpeed.ImageIndex;
  acAltSpeed.ImageIndex:=-1;
  tbtAltSpeed.ImageIndex:=i;
{$endif}
  txTransferHeader.Color:=GetLikeColor(clBtnFace, -15);
  txTorrentHeader.Color:=txTransferHeader.Color;
  txTransferHeader.Caption:=' ' + txTransferHeader.Caption;
  txTorrentHeader.Caption:=' ' + txTorrentHeader.Caption;
  txTransferHeader.Height:=txTransferHeader.Canvas.TextHeight(txTransferHeader.Caption) + 2;
  txTorrentHeader.Height:=txTorrentHeader.Canvas.TextHeight(txTorrentHeader.Caption) + 2;

  with gStats do begin
    BeginUpdate;
    try
      Items[0, 0]:=UTF8Decode(SDownloaded);
      Items[0, 1]:=UTF8Decode(SUploaded);
      Items[0, 2]:=UTF8Decode(SFilesAdded);
      Items[0, 3]:=UTF8Decode(SActiveTime);
    finally
      EndUpdate;
    end;
  end;

  if Ini.ReadInteger('MainForm', 'State', -1) = -1 then begin
    R:=Screen.MonitorFromRect(BoundsRect).WorkareaRect;
    if R.Right - R.Left < 300 then
      R:=Rect(0, 0, Screen.Width, Screen.Height);
    j:=R.Right - R.Left;
    i:=j*3 div 4;
    j:=j*95 div 100;
    if i > Width then
      Width:=i;
    if Width > j then
      Width:=j;
    Left:=(R.Right - R.Left - Width) div 2;
    j:=R.Bottom - R.Top;
    i:=j*3 div 4;
    j:=j*8 div 10;
    if i > Height then
      Height:=i;
    if Height > j then
      Height:=j;
    Top:=(R.Bottom - R.Top - Height) div 2;
  end
  else begin
    ws:=TWindowState(Ini.ReadInteger('MainForm', 'State', integer(WindowState)));
    Left:=Ini.ReadInteger('MainForm', 'Left', Left);
    Top:=Ini.ReadInteger('MainForm', 'Top', Top);
    Width:=Ini.ReadInteger('MainForm', 'Width', Width);
    Height:=Ini.ReadInteger('MainForm', 'Height', Height);
    if ws = wsMaximized then
      WindowState:=wsMaximized;
  end;

  if Ini.ReadBool('MainForm', 'FilterPane', acFilterPane.Checked) <> acFilterPane.Checked then
    acFilterPane.Execute;
  if Ini.ReadBool('MainForm', 'InfoPane', acInfoPane.Checked) <> acInfoPane.Checked then
    acInfoPane.Execute;
  if Ini.ReadBool('MainForm', 'StatusBar', acStatusBar.Checked) <> acStatusBar.Checked then
    acStatusBar.Execute;
  if Ini.ReadBool('MainForm', 'StatusBarSizes', acStatusBarSizes.Checked) <> acStatusBarSizes.Checked then
    acStatusBarSizes.Execute;

  if Ini.ReadBool('MainForm', 'Menu', acMenuShow.Checked) <> acMenuShow.Checked then
    acMenuShow.Execute;
  if Ini.ReadBool('MainForm', 'Toolbar', acToolbarShow.Checked) <> acToolbarShow.Checked then
    acToolbarShow.Execute;
  if Ini.ReadBool('MainForm', 'BigToolbar', acBigToolBar.Checked)  <> acBigToolBar.Checked then
    acBigToolbar.Execute;

  FFromNow := Ini.ReadBool('MainForm','FromNow',false);
  FWatchLocalFolder := Ini.ReadString('Interface','WatchLocalFolder','');
  if FWatchLocalFolder  <> '' then
          if DirPathExists(FWatchLocalFolder) and DirectoryIsWritable(FWatchLocalFolder) then
            begin
                FWatchLocalFolder := AppendPathDelim(FWatchLocalFolder);
                FWatchDestinationFolder := Ini.ReadString('Interface','WatchDestinationFolder','');
                LocalWatchTimer.Interval:=trunc(Ini.ReadFloat('Interface','WatchInterval',1)*60000);
                LocalWatchTimer.Enabled := true;
            end;
  LoadColumns(gTorrents, 'TorrentsList');
  TorrentColumnsChanged;
  LoadColumns(lvFiles, 'FilesList');
  LoadColumns(lvPeers, 'PeerList');
  LoadColumns(lvTrackers, 'TrackersList');

  acResolveHost.Checked:=Ini.ReadBool('PeersList', 'ResolveHost', True);
  acResolveCountry.Checked:=Ini.ReadBool('PeersList', 'ResolveCountry', True) and (GetGeoIpDatabase <> '');
  acShowCountryFlag.Checked:=Ini.ReadBool('PeersList', 'ShowCountryFlag', True) and (GetFlagsArchive <> '');
  acShowCountryFlag.Enabled:=acResolveCountry.Checked;
  FCurConn:=Ini.ReadString('Hosts', 'CurHost', '');
  if FCurConn = '' then
    FCurConn:=Ini.ReadString('Connection', 'Host', '');
  FPathMap:=TStringList.Create;
  if Application.HasOption('hidden') then begin
    ApplicationProperties.ShowMainForm:=False;
    TickTimer.Enabled:=True;
    UpdateTray;
  end;
  UpdateConnections;

  i:=Ini.ReadInteger('Interface', 'LastRpcVersion', -1);
  if i >= 0 then
    UpdateUIRpcVersion(i);

  bidiMode := GetBiDi;

  acFolderGrouping.Checked:=Ini.ReadBool('Interface', 'FolderGrouping', True);
  acLabelGrouping.Checked:=Ini.ReadBool('Interface', 'LabelGrouping', True);
  acTrackerGrouping.Checked:=Ini.ReadBool('Interface', 'TrackerGrouping', True);
  FLinksFromClipboard:=Ini.ReadBool('Interface', 'LinksFromClipboard', True);
  FCreateFolder:=Ini.ReadBool('Interface', 'CreateFolder', True);
  FGCSSID:=Ini.ReadString('NetWork','GoogleCustomSearchSID','');
  FGCSSIDAPIKey:=Ini.ReadString('NetWork','GoogleCustomSearchAPIKey','');
  
  Application.OnActivate:=@FormActivate;
  Application.OnException:=@ApplicationPropertiesException;

  {$ifdef windows}
  FFileManagerDefault:=Ini.ReadString('Interface','FileManagerDefault','explorer.exe');
  FFileManagerDefaultParam:=Ini.ReadString('Interface', 'FileManagerDefaultParam', '/select,"%s"');
  FGlobalHotkey:=Ini.ReadString('Interface','GlobalHotkey','');
  FGlobalHotkeyMod:=Ini.ReadString('Interface','GlobalHotkeyMod','0');
  HotKeyID := GlobalAddAtom('TransGUIHotkey');
  PrevWndProc:=windows.WNDPROC(SetWindowLongPtr(Self.Handle,GWL_WNDPROC,PtrInt(@WndCallback)));
  RegisterHotKey(Self.Handle,HotKeyID, VKStringToWord(FGlobalHotkeyMod), VKStringToWord(FGlobalHotkey));
  // Create UserMenus if any in [UserMenu]
      j:= 1;
      repeat
            MenuCaption := Ini.ReadString('UserMenu','Caption'+IntToStr(j),'nocaption');
            inc(J);
      until MenuCaption = 'nocaption';
      dec(j);
      if j > 0 then
        begin
          if J > 2 then
            begin
                  MI := TMenuItem.Create(Self);
                  MI.Caption:= sUserMenu;
                  MI.ImageIndex:=6;
                  pmFiles.Items.Insert(4,MI);
                  MI2 := TMenuItem.Create(Self);
                  MI2.Caption:= sUserMenu;
                  MI2.ImageIndex:=6;
                  pmTorrents.Items.Insert(2,MI2);
            end;
          for i := 1 to j-1 do
            begin
                MI := TMenuItem.Create(Self);
                MI2 := TMenuItem.Create(Self);
                MI.Caption:= Ini.ReadString('UserMenu','Caption'+IntToStr(i),'');
                if MI.Caption <> '-' then
                begin
                  MI.Tag:= 1000+i;
                  MI.OnClick:= @acOpenFileExecute;
                end;
                try
                if ExtractIconEx(PChar(Ini.ReadString('UserMenu','ExeName'+IntToStr(i),'')), 0, LargeIco, SmallIco, 1) > null then
                  begin
                        Ico := TIcon.Create;
                        try
                          Ico.Handle := SmallIco;
                          Ico.Transparent := True;
                          Ico.Masked:=True;
                        finally
                          ImageList16.AddIcon(Ico);
                          Ico.Free;
                          MI.ImageIndex := ImageList16.Count-1;
                        end;
                  end;
                except
                end;
                MI2.Caption:= MI.Caption;
                MI2.Tag:= MI.Tag;
                MI2.OnClick:=MI.OnClick;
                MI2.ImageIndex:= MI.ImageIndex;
                if j > 2 then pmFiles.Items[4].Add(MI)
                        else pmFiles.Items.Insert(4,MI);
                if j > 2 then pmTorrents.Items[2].Add(MI2)
                        else pmTorrents.Items.Insert(2,MI2);
            end;
        end;
  // end Create UserMenu
  {$else}
    {$ifdef darwin}
    FLinuxOpenDoc := Ini.ReadInteger('Interface','FileOpenDoc',0);  // macOS - OpenURL(s, p) = Original version TRGUI
    {$else}
    FLinuxOpenDoc := Ini.ReadInteger('Interface','FileOpenDoc',1);
    {$endif darwin}
    Ini.WriteInteger('Interface','FileOpenDoc',FLinuxOpenDoc);
  {$endif windows}

//Dynamic Associations of ShortCuts to Actions/Menus
  SL := TStringList.Create;
  try
    Ini.ReadSectionValues('ShortCuts', SL);
    if (SL.Text = '') or (SL.Count <> ActionList.ActionCount) then
      begin
          for i := 0 to ActionList.ActionCount-1 do
          Ini.WriteString('Shortcuts',StringReplace(ActionList.Actions[i].Name,'ac','',[]),ShortcutToText(TAction(ActionList.Actions[i]).ShortCut));
          if (i<SL.Count-1) and (SL.Text <> '') and (ActionList.ActionByName(SL.Names[i]) = nil) then Ini.WriteString('Shortcuts',StringReplace(ActionList.Actions[i].Name,'ac','',[]),ShortcutToText(TAction(ActionList.Actions[i]).ShortCut));
      end
      else
        for i := 0 to SL.Count - 1 do
              try
                  TAction(ActionList.ActionbyName('ac'+SL.Names[i])).ShortCut := TextToShortcut(SL.ValueFromIndex[i]);
              except
              end;
  finally
    SL.Free;
  end;
  // StatusBar Panels width
  i := Ini.ReadInteger('StatusBarPanels','ScreenWidth',0);
  if Screen.Width <> i then
      begin
        Ini.EraseSection('StatusBarPanels');
        Ini.WriteInteger('StatusBarPanels','ScreenWidth',Screen.Width);
      end;
  for i := 0 to StatusBar.Panels.Count-1 do
  begin
        j := Ini.ReadInteger('StatusBarPanels',IntToStr(i),0);
        if j <> 0 then StatusBar.Panels[i].Width:=j else
                  Ini.WriteInteger('StatusBarPanels',IntToStr(i),Statusbar.Panels[i].Width);
  end;
  {$IF LCL_FULLVERSION >= 1080000}
  PageInfo.Options := PageInfo.Options + [nboDoChangeOnSetIndex]
  {$ENDIF}
end;

procedure TMainForm.FormDestroy(Sender: TObject);

  procedure _CreateAllForms;
  begin
    // Create all application forms to properly update language files
    TAboutForm.Create(Self).Free;
    TAddLinkForm.Create(Self).Free;
    TAddTorrentForm.Create(Self).Free;
    TAddTrackerForm.Create(Self).Free;
    TColSetupForm.Create(Self).Free;
    TConnOptionsForm.Create(Self).Free;
    TDaemonOptionsForm.Create(Self).Free;
    TDownloadForm.Create(Self).Free;
    TMoveTorrentForm.Create(Self).Free;
    TOptionsForm.Create(Self).Free;
    TTorrPropsForm.Create(Self).Free;
  end;

begin
  if Application.HasOption('updatelang') then begin
    _CreateAllForms;
    SupplementTranslationFiles;
  end;
  if Application.HasOption('makelang') then begin
    _CreateAllForms;
    MakeTranslationFile;
  end;

  DeleteFileUTF8(FRunFileName);
  FPasswords.Free;
  FResolver.Free;
  FTrackers.Free;
  FUnZip.Free;
  RpcObj.Free;
  FTorrentProgress.Free;
  FPathMap.Free;
  FTorrents.Free;
  FPendingTorrents.Free;
  try
    Ini.UpdateFile;
  except
  end;
  {$ifdef windows}
  UnRegisterHotkey(Self.Handle,HotKeyID);
  GlobalDeleteAtom(HotKeyID);
  {$endif windows}

end;

procedure TMainForm.FormResize(Sender: TObject);
begin
  if panReconnect.Visible then
    CenterReconnectWindow;
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  if not FMainFormShown then begin
    FMainFormShown:=True;
    VSplitter.SetSplitterPosition(Ini.ReadInteger('MainForm', 'VSplitter', VSplitter.GetSplitterPosition));
    HSplitter.SetSplitterPosition(Ini.ReadInteger('MainForm', 'HSplitter', HSplitter.GetSplitterPosition));
    MakeFullyVisible;
  end;
  if not FStarted then
    TickTimer.Enabled:=True;
  UpdateTray;
end;

procedure TMainForm.lvFilterResize(Sender: TObject);
begin
  lvFilter.Columns[0].Width:=lvFilter.ClientWidth;
end;

procedure TMainForm.miAboutClick(Sender: TObject);
begin
  with TAboutForm.Create(Self) do
  try
    ShowModal;
  finally
    Free;
  end;
end;

procedure TMainForm.miCopyLabelClick(Sender: TObject);
begin
  with TLabel(pmLabels.PopupComponent) do
    if (Length(Name) > 5) and (Copy(Name, Length(Name) - 4, 5) = 'Label') then
      Clipboard.AsText:=TLabel(Parent.FindChildControl(Copy(Name, 1, Length(Name) - 5))).Caption
    else
      Clipboard.AsText:=Caption;
end;

procedure TMainForm.acConnectExecute(Sender: TObject);
begin
  if RpcObj.Connected then begin
    tbConnect.CheckMenuDropdown;
    exit;
  end;
  if FCurConn = '' then
    ShowConnOptions(True)
  else
    DoConnect;
end;

procedure TMainForm.acConnOptionsExecute(Sender: TObject);
begin
  ShowConnOptions(False);
end;

procedure TMainForm.acCopyPathExecute(Sender: TObject);
begin
  if lvFiles.Items.Count > 0 then
    Clipboard.AsText:='"' + FFilesTree.GetFullPath(lvFiles.Row) + '"';
end;

procedure TMainForm.acDelTrackerExecute(Sender: TObject);
var
  req, args: TJSONObject;
  id, torid: integer;
begin
  id:=lvTrackers.Items[idxTrackerID, lvTrackers.Row];
  torid:=RpcObj.CurTorrentId;
  if MessageDlg('', Format(SRemoveTracker, [UTF8Encode(widestring(lvTrackers.Items[idxTrackersListName, lvTrackers.Row]))]), mtConfirmation, mbYesNo, 0, mbNo) <> mrYes then exit;
  AppBusy;
  Self.Update;
  req:=TJSONObject.Create;
  try
    req.Add('method', 'torrent-set');
    args:=TJSONObject.Create;
    args.Add('ids', TJSONArray.Create([torid]));
    args.Add('trackerRemove', TJSONArray.Create([id]));
    req.Add('arguments', args);
    args:=nil;
    args:=RpcObj.SendRequest(req, False);
    if args = nil then begin
      CheckStatus(False);
      exit;
    end;
    args.Free;
  finally
    req.Free;
  end;
  DoRefresh;
  AppNormal;
end;

procedure TMainForm.acEditTrackerExecute(Sender: TObject);
begin
  AddTracker(True);
end;

procedure TMainForm.acFilterPaneExecute(Sender: TObject);
begin
  acFilterPane.Checked:=not acFilterPane.Checked;
  panFilter.Visible:=acFilterPane.Checked;
  HSplitter.Visible:=acFilterPane.Checked;
  HSplitter.Left:=panFilter.Width;
  if lvFilter.Items.Count > 0 then
    lvFilter.Row:=0;
end;

procedure TMainForm.acFolderGroupingExecute(Sender: TObject);
begin
  acFolderGrouping.Checked:=not acFolderGrouping.Checked;
  Ini.WriteBool('Interface', 'FolderGrouping', acFolderGrouping.Checked);
  RpcObj.RefreshNow:=RpcObj.RefreshNow + [rtTorrents];
end;

procedure TMainForm.acForceStartTorrentExecute(Sender: TObject);
begin
  TorrentAction(GetSelectedTorrents, 'torrent-start-now');
end;

procedure TMainForm.acHideAppExecute(Sender: TObject);
begin
  HideApp;
end;

procedure TMainForm.acInfoPaneExecute(Sender: TObject);
begin
  acInfoPane.Checked:=not acInfoPane.Checked;
  PageInfo.Visible:=acInfoPane.Checked;
  VSplitter.Top:=PageInfo.Top - VSplitter.Height;
  VSplitter.Visible:=acInfoPane.Checked;
  if VSplitter.Visible then
    PageInfoChange(nil)
  else
    RpcObj.AdvInfo:=aiNone;
end;

procedure TMainForm.acLabelGroupingExecute(Sender: TObject);
begin
  acLabelGrouping.Checked:=not acLabelGrouping.Checked;
  Ini.WriteBool('Interface', 'LabelGrouping', acLabelGrouping.Checked);
  RpcObj.RefreshNow:=RpcObj.RefreshNow + [rtTorrents];
end;

procedure TMainForm.acMenuShowExecute(Sender: TObject);
begin
    acMenuShow.Checked:=not acMenuShow.Checked;
    if acMenuShow.Checked = false then
      MainForm.Menu := nil
    else
      MainForm.Menu := MainMenu;
end;

procedure TMainForm.acMoveTorrentExecute(Sender: TObject);
var
  ids: variant;
  i: integer;
  s: string;
  req: TJSONObject;
  aids: TJSONArray;
  args: TJSONObject;
  ok: boolean;
  t: TDateTime;
begin
  if gTorrents.Items.Count = 0 then
    exit;
  AppBusy;
  with TMoveTorrentForm.Create(Self) do
  try
    gTorrents.Tag:=1;
    gTorrents.EnsureSelectionVisible;
    FillDownloadDirs(edTorrentDir, 'LastMoveDir');
    if gTorrents.SelCount = 0 then
      gTorrents.RowSelected[gTorrents.Row]:=True;
    ids:=GetSelectedTorrents;
    i:=gTorrents.Items.IndexOf(idxTorrentId, ids[0]);
    if VarIsEmpty(gTorrents.Items[idxPath, i]) then
      exit;

    edTorrentDir.Text:=UTF8Encode(widestring(gTorrents.Items[idxPath, i]));

    if gTorrents.SelCount > 1 then
      s:=Format(sSeveralTorrents, [gTorrents.SelCount])
    else
      s:=UTF8Encode(widestring(gTorrents.Items[idxName, i]));


    Caption:=Caption + ' - ' + s;
    AppNormal;
    if ShowModal = mrOk then begin
      Application.ProcessMessages;
      AppBusy;
      req:=TJSONObject.Create;
      try
        req.Add('method', 'torrent-set-location');
        args:=TJSONObject.Create;
        aids:=TJSONArray.Create;
        for i:=VarArrayLowBound(ids, 1) to VarArrayHighBound(ids, 1) do
          aids.Add(integer(ids[i]));
        args.Add('ids', aids);
        args.Add('location', TJSONString.Create(UTF8Decode(edTorrentDir.Text)));
        args.Add('move', TJSONIntegerNumber.Create(integer(cbMoveData.Checked) and 1));
        req.Add('arguments', args);
        args:=RpcObj.SendRequest(req, False);
        args.Free;
      finally
        req.Free;
      end;
      gTorrents.Tag:=0;
      AppNormal;
      if args = nil then
        CheckStatus(False)
      else begin
        SaveDownloadDirs(edTorrentDir, 'LastMoveDir');
        ok:=False;
        t:=Now;
        with gTorrents do
          while not ok and not Application.Terminated and (Now - t < 20/SecsPerDay) do begin
            RpcObj.RequestFullInfo:=True;
            DoRefresh(True);
            Sleep(200);
            Application.ProcessMessages;
            ok:=True;
            for i:=0 to Items.Count - 1 do
              if RowSelected[i] then begin
                if VarIsEmpty(Items[idxPath, i]) or (AnsiCompareText(UTF8Encode(widestring(Items[idxPath, i])), edTorrentDir.Text) <> 0) then begin
                  ok:=False;
                  break;
                end;
              end;
          end;
      end;
    end;
  finally
    gTorrents.Tag:=0;
    Free;
  end;
end;

procedure TMainForm.acNewConnectionExecute(Sender: TObject);
begin
  ShowConnOptions(True);
end;

procedure TMainForm.acOpenContainingFolderExecute(Sender: TObject);
begin
  if gTorrents.Items.Count = 0 then
    exit;
  Application.ProcessMessages;
  if lvFiles.Focused and (lvFiles.Items.Count > 0) then begin
    AppBusy;
    ExecRemoteFile(FFilesTree.GetFullPath(lvFiles.Row), not FFilesTree.IsFolder(lvFiles.Row));
    AppNormal;
  end
  else
    OpenCurrentTorrent(True);
end;

procedure TMainForm.acOpenFileExecute(Sender: TObject);
var UserDef: boolean;
begin
  if gTorrents.Items.Count = 0 then
    exit;
  Application.ProcessMessages;
  if (Sender is TMenuItem) and (TMenuItem(Sender).Tag > 999) then
    begin
        UserDef := true;
        {$ifdef windows}
        FUserDefinedMenuEx    := Ini.ReadString('UserMenu','ExeName'+IntToStr(TMenuItem(Sender).Tag-1000),'');
        FUserDefinedMenuParam := Ini.ReadString('UserMenu','Params'+IntToStr(TMenuItem(Sender).Tag-1000),'');
        {$endif windows}
    end
      else UserDef := false;
  if lvFiles.Focused then begin
    if lvFiles.Items.Count = 0 then exit;
    ExecRemoteFile(FFilesTree.GetFullPath(lvFiles.Row), False, Userdef)
  end
  else
    OpenCurrentTorrent(False, UserDef);
end;

procedure TMainForm.acOptionsExecute(Sender: TObject);
var
  OldCheckVer: boolean;
begin
  AppBusy;
  with TOptionsForm.Create(Self) do
  try
    ConnForm.ActiveConnection:=FCurConn;
    edRefreshInterval.Value:=Ini.ReadInteger('Interface', 'RefreshInterval', 5);
    edRefreshIntervalMin.Value:=Ini.ReadInteger('Interface', 'RefreshIntervalMin', 20);
    cbCalcAvg.Checked:=FCalcAvg;
{$ifndef darwin}
    cbTrayMinimize.Checked:=Ini.ReadBool('Interface', 'TrayMinimize', True);
{$else}
    cbTrayMinimize.Enabled:=False;
{$endif}
    cbTrayClose.Checked:=Ini.ReadBool('Interface', 'TrayClose', False);
    cbTrayIconAlways.Checked:=Ini.ReadBool('Interface', 'TrayIconAlways', True);
    cbTrayNotify.Checked:=Ini.ReadBool('Interface', 'TrayNotify', True);

    cbShowAddTorrentWindow.Checked:=Ini.ReadBool('Interface', 'ShowAddTorrentWindow', True);
    cbDeleteTorrentFile.Checked:=Ini.ReadBool('Interface', 'DeleteTorrentFile', False);
    cbLinksFromClipboard.Checked:=Ini.ReadBool('Interface', 'LinksFromClipboard', True);
    cbCreateFolder.Checked:=Ini.ReadBool('Interface', 'CreateFolder', True);
    edIntfScale.Value:=Ini.ReadInteger('Interface', 'Scaling', 100);
    cbCheckNewVersion.Checked:=Ini.ReadBool('Interface', 'CheckNewVersion', False);
    edCheckVersionDays.Value:=Ini.ReadInteger('Interface', 'CheckNewVersionDays', 5);
    cbCheckNewVersionClick(nil);
    OldCheckVer:=cbCheckNewVersion.Checked;
{$ifdef linux}
    if IsUnity then begin
      cbTrayIconAlways.Enabled:=False;
      cbTrayIconAlways.Checked:=False;
      cbTrayMinimize.Enabled:=False;
      cbTrayMinimize.Checked:=False;
      cbTrayNotify.Enabled:=False;
      cbTrayNotify.Checked:=False;
    end;
{$endif linux}
    AppNormal;
    if ShowModal = mrOk then begin
      AppBusy;
      Ini.WriteInteger('Interface', 'RefreshInterval', edRefreshInterval.Value);
      Ini.WriteInteger('Interface', 'RefreshIntervalMin', edRefreshIntervalMin.Value);
      Ini.WriteBool('Interface', 'CalcAvg', cbCalcAvg.Checked);
{$ifndef darwin}
      Ini.WriteBool('Interface', 'TrayMinimize', cbTrayMinimize.Checked);
{$endif}
      Ini.WriteBool('Interface', 'TrayClose', cbTrayClose.Checked);
      Ini.WriteBool('Interface', 'TrayIconAlways', cbTrayIconAlways.Checked);
      Ini.WriteBool('Interface', 'TrayNotify', cbTrayNotify.Checked);

      Ini.WriteBool('Interface', 'ShowAddTorrentWindow', cbShowAddTorrentWindow.Checked);
      Ini.WriteBool('Interface', 'DeleteTorrentFile', cbDeleteTorrentFile.Checked);
      Ini.WriteBool('Interface', 'LinksFromClipboard', cbLinksFromClipboard.Checked);
      Ini.WriteBool('Interface', 'CreateFolder', cbCreateFolder.Checked);
      FLinksFromClipboard:=cbLinksFromClipboard.Checked;
      FCreateFolder:=cbCreateFolder.Checked;

      Ini.WriteInteger('Interface', 'Scaling', edIntfScale.Value);

      Ini.WriteBool('Interface', 'CheckNewVersion', cbCheckNewVersion.Checked);
      Ini.WriteInteger('Interface', 'CheckNewVersionDays', edCheckVersionDays.Value);

      if cbCheckNewVersion.Checked and not OldCheckVer then
        CheckNewVersion;
      Ini.UpdateFile;
      UpdateTray;
      AppNormal;
      with ConnForm do
        ConnectionSettingsChanged(ActiveConnection, ActiveSettingChanged);
    end;
  finally
    Free;
  end;
end;

procedure TMainForm.acAddTorrentExecute(Sender: TObject);
begin
  if not OpenTorrentDlg.Execute then exit;
  FPendingTorrents.AddStrings(OpenTorrentDlg.Files);
  TickTimerTimer(nil);
end;

procedure TMainForm.acAddTrackerExecute(Sender: TObject);
begin
  AddTracker(False);
end;

procedure TMainForm.acAdvEditTrackersExecute(Sender: TObject);
begin
  gTorrents.RemoveSelection;
  TorrentProps(1);
end;

procedure TMainForm.acAltSpeedExecute(Sender: TObject);
var
  req, args: TJSONObject;
begin
  AppBusy;
  req:=TJSONObject.Create;
  try
    req.Add('method', 'session-set');
    args:=TJSONObject.Create;
    args.Add('alt-speed-enabled', integer(not acAltSpeed.Checked) and 1);
    req.Add('arguments', args);
    args:=RpcObj.SendRequest(req, False);
    if args = nil then begin
      CheckStatus(False);
      exit;
    end;
    args.Free;
  finally
    req.Free;
  end;
  RpcObj.RefreshNow:=RpcObj.RefreshNow + [rtSession];
  AppNormal;
end;

procedure TMainForm.acBigToolbarExecute(Sender: TObject);
begin
  acBigToolbar.Checked:=not acBigToolbar.Checked;
  if acBigToolbar.Checked then begin
    MainToolBar.ButtonWidth:= Ini.ReadInteger('MainForm','BigToolBarHeight',64);
    MainToolBar.ButtonHeight:= MainToolBar.ButtonWidth;
    MainToolBar.Images:= ImageList32;
  end else begin
    MainToolBar.ButtonWidth:= 23;
    MainToolBar.ButtonHeight:=23;
    MainToolBar.Images:= ImageList16;
    end;
  Ini.WriteBool('MainForm', 'BigToolbar', acBigToolbar.Checked);
end;

procedure TMainForm.acCheckNewVersionExecute(Sender: TObject);
begin
  Application.ProcessMessages;
  AppBusy;
  CheckNewVersion(False);
  AppNormal;
end;

procedure TMainForm.acAddLinkExecute(Sender: TObject);
begin
  AppBusy;
  with TAddLinkForm.Create(Self) do
  try
    AppNormal;
    if ShowModal = mrOk then
      begin
          if isHash(edLink.Text) then edLink.Text := 'magnet:?xt=urn:btih:'+ edLink.Text;
          DoAddTorrent(edLink.Text);
      end;
  finally
    Free;
  end;
end;

function TMainForm.DoAddTorrent(const FileName: Utf8String): boolean;
var
  torrent: string;
  WaitForm: TBaseForm;
  IsAppHidden: boolean;

  Procedure _AddTrackers(TorrentId: integer);
  var
    req, args: TJSONObject;
    fs: TFileStreamUTF8;
    TorData, AnnData, LData, LLData: TBEncoded;
    t: TJSONArray;
    tt: TJSONObject;
    trackers: TJSONArray;
    i, j: Integer;
    s, tfn, TorrentHash: string;
    TrackersList: TStringList;
  begin
    RpcObj.Status:='';
    s:='';
    if TorrentId <> 0 then begin
      i:=SelectTorrent(TorrentId, 2000);
      if i >= 0 then
        s:=Format(': %s', [UTF8Encode(widestring(gTorrents.Items[idxName, i]))]);

    end;
    ForceAppNormal;
    s:=TranslateString(SDuplicateTorrent + s + '.', True);
    if RpcObj.RPCVersion < 10 then begin
      MessageDlg(s, mtError, [mbOK], 0);
      exit;
    end;
    if MessageDlg(s + LineEnding + LineEnding + SUpdateTrackers, mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
      exit;
    Application.ProcessMessages;
    TrackersList:=TStringList.Create;
    try
      TorrentHash:='';
      if AnsiCompareText('magnet:?', Copy(FileName, 1, 8)) = 0 then begin
        // Get trackers from the magnet link
        TrackersList.Delimiter:='&';
        TrackersList.DelimitedText:=Copy(FileName, 9, MaxInt);
        i:=0;
        while i < TrackersList.Count do begin
          s:=TrackersList.Names[i];
          if (TorrentId = 0) and (CompareText(s, 'xt') = 0) then begin
            s:=LowerCase(TrackersList.ValueFromIndex[i]);
            if (TorrentHash = '') and (Pos('urn:btih:', s) = 1) then begin
              s:=Copy(s, 10, MaxInt);
              if Length(s) = 32 then
                // base32 encoded hash
                TorrentHash:=StrToHex(Base32Decode(UpperCase(s)))
              else
                TorrentHash:=s;
            end;
          end
          else
            if CompareText(s, 'tr') = 0 then begin
              TrackersList[i]:=DecodeURL(TrackersList.ValueFromIndex[i]);
              Inc(i);
              continue;
            end;
          TrackersList.Delete(i);
        end;
      end
      else
      try
        if IsProtocolSupported(FileName) then begin
          // Downloading torrent file
          tfn:=SysToUTF8(GetTempDir(True)) + 'remote-torrent.torrent';
          if not DownloadFile(FileName, ExtractFilePath(tfn), ExtractFileName(tfn), SDownloadingTorrent) then
            exit;
        end
        else
          tfn:=FileName;
        // Read trackers from the torrent file...
        AppBusy;
        TorData:=nil;
        fs:=TFileStreamUTF8.Create(tfn, fmOpenRead or fmShareDenyNone);
        try
          TorData:=TBEncoded.Create(fs);
          if TorrentId = 0 then begin
            // Calculate torrent hash
            LData:=(TorData.ListData.FindElement('info') as TBEncoded);
            s:='';
            LData.Encode(LData, s);
            TorrentHash:=StrToHex(SHA1(s));
          end;
          AnnData:=(TorData.ListData.FindElement('announce-list', False) as TBEncoded);
          if AnnData <> nil then
            for i:=0 to AnnData.ListData.Count - 1 do begin
              LData:=AnnData.ListData.Items[i].Data as TBEncoded;
              for j:=0 to LData.ListData.Count - 1 do begin
                LLData:=LData.ListData.Items[j].Data as TBEncoded;
                TrackersList.Add(LLData.StringData);
              end;
            end
          else begin
            AnnData:=(TorData.ListData.FindElement('announce', False) as TBEncoded);
            if AnnData <> nil then
              TrackersList.Add(AnnData.StringData);
          end;
        finally
          TorData.Free;
          fs.Free;
        end;
      finally
        // Delete temp file
        if (tfn <> '') and (tfn <> FileName) then
          DeleteFileUTF8(tfn);
      end;

      // Request trackers from the existing torrent
      req:=TJSONObject.Create;
      try
        req.Add('method', 'torrent-get');
        args:=TJSONObject.Create;
        if TorrentId = 0 then
          args.Add('ids', TJSONArray.Create([TorrentHash]))
        else
          args.Add('ids', TJSONArray.Create([TorrentId]));
        args.Add('fields', TJSONArray.Create(['id', 'trackers']));
        req.Add('arguments', args);
        args:=RpcObj.SendRequest(req);
        if args = nil then begin
          CheckStatus(False);
          exit;
        end;
        try
          t:=args.Arrays['torrents'];
          if t.Count = 0 then
            raise Exception.Create('Torrent not found.');
          tt:=t.Objects[0] as TJSONObject;
          i:=tt.Integers['id'];
          if TorrentId = 0 then
            SelectTorrent(i, 2000);
          TorrentId:=i;
          trackers:=tt.Arrays['trackers'];
          // Deleting existing trackers from the list
          for i:=0 to trackers.Count - 1 do begin
            s:=UTF8Encode((Trackers.Items[i] as TJSONObject).Strings['announce']);
            j:=TrackersList.IndexOf(s);
            if j >= 0 then
              TrackersList.Delete(j);
          end;
        finally
          args.Free;
        end;
      finally
        req.Free;
      end;

      if TrackersList.Count > 0 then begin
        trackers:=TJSONArray.Create;
        for i:=0 to TrackersList.Count - 1 do
          trackers.Add(TrackersList[i]);
        args:=TJSONObject.Create;
        args.Add('ids', TJSONArray.Create([TorrentId]));
        args.Add('trackerAdd', trackers);
        req:=TJSONObject.Create;
        try
          req.Add('method', 'torrent-set');
          req.Add('arguments', args);
          args:=RpcObj.SendRequest(req, False);
          if args = nil then begin
            CheckStatus(False);
            exit;
          end;
          args.Free;
        finally
          req.Free;
        end;
        DoRefresh;
      end;
    finally
      TrackersList.Free;
      AppNormal;
    end;
  end;

  function _AddTorrent(args: TJSONObject): integer;
  var
    req: TJSONObject;
  begin
    Result:=0;
    req:=TJSONObject.Create;
    try
      req.Add('method', 'torrent-add');
      if torrent = '-' then
        args.Add('filename', TJSONString.Create(FileName))
      else
        args.Add('metainfo', TJSONString.Create(torrent));
      req.Add('arguments', args);
      args:=RpcObj.SendRequest(req);
      if args <> nil then
      try
        if args.IndexOfName('torrent-duplicate') >= 0 then begin
          _AddTrackers(args.Objects['torrent-duplicate'].Integers['id']);
          exit;
        end;
        Result:=args.Objects['torrent-added'].Integers['id'];
      finally
        args.Free;
      end
      else
        if RpcObj.Status='duplicate torrent' then begin
          _AddTrackers(0);
          exit;
        end;
    finally
      req.Free;
    end;
    if Result = 0 then
      CheckStatus(False);
  end;

  procedure ShowWaitMsg(const AText: string);
  begin
    if WaitForm = nil then begin
      WaitForm:=TBaseForm.CreateNew(Self);
      with WaitForm do begin
{$ifndef windows}
        if IsAppHidden then
          ShowInTaskBar:=stAlways;
{$endif windows}
        Caption:=AppName;
        BorderStyle:=bsToolWindow;
        BorderIcons:=[];
        Position:=poScreenCenter;
        Constraints.MinWidth:=400;
        AutoSize:=True;
        BorderWidth:=ScaleInt(16);
        with TLabel.Create(WaitForm) do begin
          Alignment:=taCenter;
          Align:=alClient;
          Parent:=WaitForm;
        end;
      end;
    end;
    with WaitForm do begin
      TLabel(Controls[0]).Caption:=AText + '...';
      Show;
      BringToFront;
{$ifdef lclgtk2}
      Application.ProcessMessages;
{$endif lclgtk2}
      Update;
{$ifdef lclgtk2}
      sleep(100);
      Application.ProcessMessages;
{$endif lclgtk2}
    end;
  end;

  procedure HideWaitMsg;
  begin
    if WaitForm <> nil then
      FreeAndNil(WaitForm);
  end;

var
  req, args: TJSONObject;
  id: integer;
  t, files: TJSONArray;
  i, j: integer;
  fs: TFileStreamUTF8;
  s, ss, OldDownloadDir, IniSec, OldName, stKODIPath: string;
  ok: boolean;
  pFD:FolderData;
  lstKodiUrl: TStringList;
begin
  Result:=False;
  if not RpcObj.Connected and not RpcObj.Connecting then
    if not DoConnect then
      exit;
  WaitForm:=nil;
  id:=0;
  Inc(FAddingTorrent);
  try
    AppBusy;
    try
      IsAppHidden:=not Self.Visible or (Self.WindowState = wsMinimized);
      with TAddTorrentForm.Create(Self) do
      try
        if IsAppHidden then begin
          ShowWaitMsg(Caption);
{$ifndef windows}
          ShowInTaskBar:=stAlways;
{$endif windows}
        end;

        Application.ProcessMessages;
        if IsProtocolSupported(FileName) then
          torrent:='-'
        else begin
          try
            fs:=TFileStreamUTF8.Create(FileName, fmOpenRead or fmShareDenyNone); // why isnt in try
          except
            AppNormal;    // if the clipboard garbage and file cant be created. just go out.
            HideWaitMsg;
            exit;
          end;

          try
            SetLength(torrent, fs.Size);
            fs.ReadBuffer(PChar(torrent)^, Length(torrent));
          finally
            fs.Free;
          end;
          torrent:=EncodeBase64(torrent);
          TorrentFile:=FileName;
        end;

        IniSec:='AddTorrent.' + FCurConn;
        FillDownloadDirs(cbDestFolder, 'LastDownloadDir');
        if (FWatchDownloading) and (FWatchDestinationFolder <> '') then cbDestFolder.Text:=FWatchDestinationFolder;

        req:=TJSONObject.Create;
        try
          req.Add('method', 'session-get');
          args:=RpcObj.SendRequest(req);
          if args = nil then begin
            CheckStatus(False);
            exit;
          end;
          s:=CorrectPath (UTF8Encode(args.Strings['download-dir']) );
          try
            if cbDestFolder.Items.IndexOf(s) < 0 then begin
              pFD    := FolderData.create;
              pFD.Hit:= 1;
              pFD.Ext:= '';
              pFD.Txt:= s;
              pFD.Lst:= SysUtils.Date;
              cbDestFolder.Items.Add(s);
              i := cbDestFolder.Items.IndexOf(s);
              cbDestFolder.Items.Objects[i]:= pFD;
            end;
          except
            MessageDlg('Error: LS-005. Please contact the developer', mtError, [mbOK], 0);
          end;

          if RpcObj.RPCVersion < 15 then
            if args.IndexOfName('download-dir-free-space') >= 0 then
              txDiskSpace.Caption:=txDiskSpace.Caption + ' ' + GetHumanSize(args.Floats['download-dir-free-space'])
            else begin
              txDiskSpace.Hide;
              txSize.Top:=(txSize.Top + txDiskSpace.Top) div 2;
            end;
          args.Free;
        finally
          req.Free;
        end;

        lvFilter.Row:=0;
        edSearch.Text:='';

        args:=TJSONObject.Create;
        args.Add('paused', TJSONIntegerNumber.Create(1));
        i:=Ini.ReadInteger(IniSec, 'PeerLimit', 0);
        if i <> 0 then
          args.Add('peer-limit', TJSONIntegerNumber.Create(i));

        // for larazur 1.4 and up.
        // data can be in the drop-down list, but no text is selected in the window
        try
          ss := cbDestFolder.Text;
          if (ss = '') then begin
            if (cbDestFolder.Items.Count = 0) then begin
              ss := s;
            end else begin
              cbDestFolder.ItemIndex:=0;
              ss := cbDestFolder.Text;
            end;
          end;
        except
          MessageDlg('Error: LS-006. Please contact the developer', mtError, [mbOK], 0);
        end;
        args.Add('download-dir', TJSONString.Create(UTF8Decode(ss)));
        id:=_AddTorrent(args);
        if id = 0 then
          exit;

        DoRefresh(True);

        args:=RpcObj.RequestInfo(id, ['files','maxConnectedPeers','name','metadataPercentComplete', 'hashString']);
        if args = nil then begin
          CheckStatus(False);
          exit;
        end;
        try
          t:=args.Arrays['torrents'];
          if t.Count = 0 then
            raise Exception.Create(sUnableGetFilesList);

          TorrentHash := UTF8Encode(t.Objects[0].Strings['hashString']);
          OldName:=UTF8Encode(t.Objects[0].Strings['name']);
          edSaveAs.Caption:=OldName;
          edSaveAs.Caption := ExcludeInvalidChar(edSaveAs.Caption); // petrov - Exclude prohibited characters
          //searching data
          begin
            j:=0;
            for i:=0 to Length(edSaveAs.Text) - 1 do
              if ord(edSaveAs.Text[i+1]) in [ord('0')..ord('9')] then
                 begin
                   j:=j+1;
                   if j >= 4 then
                   begin
                     edFilmQuery.Text:= LeftBStr(edSaveAs.Text, i+1);
                     break;
                   end;
                 end
                 else j:=0;
            if edFilmQuery.Text = '' then
               edFilmQuery.Text:= edSaveAs.Text;
            btRefreshClick(nil);
          end;

          if RpcObj.RPCVersion < 15 then begin
            edSaveAs.Enabled:=False;
            edSaveAs.ParentColor:=True;
          end;
          edPeerLimit.Value:=t.Objects[0].Integers['maxConnectedPeers'];
          FilesTree.FillTree(id, t.Objects[0].Arrays['files'], nil, nil);
          Width:=Ini.ReadInteger('AddTorrent', 'Width', Width);
          if (RpcObj.RPCVersion >= 7) and (lvFiles.Items.Count = 0) and (t.Objects[0].Floats['metadataPercentComplete'] <> 1.0) then begin
            // Magnet link
            gbContents.Hide;
            gbSaveAs.BorderSpacing.Bottom:=gbSaveAs.BorderSpacing.Top;
            BorderStyle:=bsDialog;
            AutoSizeForm(TCustomForm(gbContents.Parent));
            edSaveAs.Enabled:=False;
            edSaveAs.ParentColor:=True;
          end
          else
            // Torrent file
            Height:=Ini.ReadInteger('AddTorrent', 'Height', Height);
        finally
          args.Free;
        end;
        OldDownloadDir:=cbDestFolder.Text;
        AppNormal;

        ok:=not Ini.ReadBool('Interface', 'ShowAddTorrentWindow', True);
        if FWatchDownloading then ok:= true;
        if ok then
          btSelectAllClick(nil)
        else begin
          HideWaitMsg;
          ok:=ShowModal = mrOk;
          if BorderStyle = bsSizeable then begin
            Ini.WriteInteger('AddTorrent', 'Width', Width);
            Ini.WriteInteger('AddTorrent', 'Height', Height);
          end;
        end;

        if ok then begin
          if IsAppHidden then
            ShowWaitMsg(Caption);
          AppBusy;
          Self.Update;

          if OldDownloadDir <> GetFullDestFolder() then begin
            TorrentAction(id, 'torrent-remove');
            id:=0;
            args:=TJSONObject.Create;
            args.Add('paused', TJSONIntegerNumber.Create(1));
            args.Add('peer-limit', TJSONIntegerNumber.Create(edPeerLimit.Value));

            args.Add('download-dir', TJSONString.Create((GetFullDestFolder()))); // Lazarus 1.4.4

            id:=_AddTorrent(args);
            if id = 0 then
              exit;
            DoRefresh(True);
            Application.ProcessMessages;
          end;

          req:=TJSONObject.Create;
          try
            req.Add('method', 'torrent-set');
            args:=TJSONObject.Create;
            args.Add('ids', TJSONArray.Create([id]));
            args.Add('peer-limit', TJSONIntegerNumber.Create(edPeerLimit.Value));

            files:=TJSONArray.Create;
            for i:=0 to lvFiles.Items.Count - 1 do
              if not FilesTree.IsFolder(i) and (FilesTree.Checked[i] = cbChecked) then
                files.Add(integer(lvFiles.Items[idxFileId, i]));
            if files.Count > 0 then
              args.Add('files-wanted', files)
            else
              files.Free;

            files:=TJSONArray.Create;
            for i:=0 to lvFiles.Items.Count - 1 do
              if not FilesTree.IsFolder(i) and (FilesTree.Checked[i] <> cbChecked) then
                files.Add(integer(lvFiles.Items[idxFileId, i]));
            if files.Count > 0 then
              args.Add('files-unwanted', files)
            else
              files.Free;

            req.Add('arguments', args);
            args:=nil;
            args:=RpcObj.SendRequest(req, False);
            if args = nil then begin
              CheckStatus(False);
              exit;
            end;
            args.Free;

//          edSaveAs.Text := Trim(edSaveAs.Text);               // leave spaces to not rename the torrent (see below)
            edSaveAs.Text := ExcludeInvalidChar(edSaveAs.Text); // Exclude prohibited characters

            if OldName <> edSaveAs.Text then begin
              // Changing torrent name
              req.Free;
              req:=TJSONObject.Create;
              req.Add('method', 'torrent-rename-path');
              args:=TJSONObject.Create;
              args.Add('ids', TJSONArray.Create([id]));
              args.Add('path', UTF8Decode(OldName));
              args.Add('name', UTF8Decode(edSaveAs.Text));
              req.Add('arguments', args);
              args:=nil;
              args:=RpcObj.SendRequest(req, False);
              if args = nil then begin
                // CheckStatus(False); // failed to rename torrent
                // exit;               // we continue work (try)
              end;
              args.Free;
            end;
          finally
            req.Free;
          end;

          if cbStartTorrent.Checked then
            TorrentAction(id, 'torrent-start');

          SelectTorrent(id, 2000);

          id:=0;
          if (Ini.ReadBool('Interface', 'DeleteTorrentFile', False) and not IsProtocolSupported(FileName)) or (FWatchDownloading) then
            DeleteFileUTF8(FileName);

          Ini.WriteInteger(IniSec, 'PeerLimit', edPeerLimit.Value);
          SaveDownloadDirs(cbDestFolder, 'LastDownloadDir');
          if (cbFilmSearch.Checked) and (FFilmUrl <> '') then
            if Trim(FPathMap.Text) = '' then
            begin
              MessageDlg(sNoPathMapping, mtInformation, [mbOK], 0);
            end
            else
            begin
              lstKodiUrl:= TStringList.Create;
              lstKodiUrl.Add(FFilmUrl);
              stKODIPath:=MainForm.PubMapRemoteToLocal(GetFullDestFolder());
              CreateDirUTF8(stKODIPath);
              stKODIPath:=stKODIPath+'\'
                +AnsiLeftStr(edSaveAs.Text, LastDelimiter('.',edSaveAs.Text))+'nfo';
              lstKodiUrl.SaveToFile(UTF8ToSys(stKODIPath));
              lstKodiUrl.Free;
            end;
          Result:=True;
          AppNormal;
        end;
      finally
        Free;
      end;
    finally
      if id <> 0 then
        TorrentAction(id, 'torrent-remove');
    end;
  finally
    HideWaitMsg;
    Dec(FAddingTorrent);
  end;
end;

procedure TMainForm.UpdateTray;
begin
{$ifndef CPUARM}
  TrayIcon.Visible:=not IsUnity and
    (Ini.ReadBool('Interface', 'TrayIconAlways', True)  or
    ((WindowState = wsMinimized) and Ini.ReadBool('Interface', 'TrayMinimize', True) ) or
    (not Self.Visible and Ini.ReadBool('Interface', 'TrayClose', False) )
    );
{$endif CPUARM}

{$ifdef darwin}
  acShowApp.Visible:=False;
  acHideApp.Visible:=False;
  miTSep1.Visible:=False;
{$else}
  acHideApp.Visible:=Visible and (WindowState <> wsMinimized);
{$endif darwin}
  SetRefreshInterval;
  FCalcAvg:=Ini.ReadBool('Interface', 'CalcAvg', True);
end;

procedure TMainForm.HideApp;
begin
  if WindowState <> wsMinimized then
    Hide;
  HideTaskbarButton;
  UpdateTray;
end;

procedure TMainForm.ShowApp;
var
  i: integer;
begin
  ShowTaskbarButton;
  if WindowState = wsMinimized then
    Application.Restore;
  Application.ProcessMessages;
  Show;
  Application.BringToFront;
  BringToFront;
  for i:=0 to Screen.FormCount - 1 do
    with Screen.Forms[i] do
      if fsModal in FormState then
        BringToFront;
  UpdateTray;
end;

procedure TMainForm.DownloadFinished(const TorrentName: string);
begin
{$ifndef CPUARM}
  if not TrayIcon.Visible or not Ini.ReadBool('Interface', 'TrayNotify', True) then exit;
  TrayIcon.BalloonHint:=Format(sFinishedDownload, [TorrentName]);
  TrayIcon.BalloonTitle:=sDownloadComplete;
  TrayIcon.ShowBalloonHint;
{$endif CPUARM}
end;

Procedure TMainForm.DoOpenFlagsZip(Sender: TObject; var AStream: TStream);
begin
  AStream:=TFileStreamUTF8.Create(TUnZipper(Sender).FileName, fmOpenRead or fmShareDenyWrite);
end;

Procedure TMainForm.DoCreateOutZipStream(Sender : TObject; var AStream : TStream; AItem : TFullZipFileEntry);
begin
  ForceDirectoriesUTF8(FFlagsPath);
  AStream:=TFileStreamUTF8.Create(FFlagsPath + AItem.DiskFileName, fmCreate);
end;

function TMainForm.GetFlagImage(const CountryCode: string): integer;
var
  s, ImageName: string;
  pic: TPicture;
  fs: TFileStreamUTF8;
begin
  Result:=0;
  if CountryCode = '' then exit;
  try
    ImageName:=CountryCode + '.png';
    if FFlagsPath = '' then
      FFlagsPath:=FHomeDir + 'flags' + DirectorySeparator;
    if not FileExistsUTF8(FFlagsPath + ImageName) then begin
      // Unzipping flag image
      if FUnZip = nil then begin
        s:=GetFlagsArchive;
        if s <> '' then begin
          FUnZip:=TUnZipper.Create;
          FUnZip.FileName:=s;
          FUnZip.OnOpenInputStream:=@DoOpenFlagsZip;
          FUnZip.OnCreateStream:=@DoCreateOutZipStream;
        end
        else
          exit;
      end;

      FUnZip.Files.Clear;
      FUnZip.Files.Add(ImageName);
      try
        FUnZip.UnZipAllFiles;
      except
        FreeAndNil(FUnZip);
        DeleteFileUTF8(GetFlagsArchive);
        acShowCountryFlag.Checked:=False;
        MessageDlg(sUnableExtractFlag + LineEnding + Exception(ExceptObject).Message, mtError, [mbOK], 0);
        exit;
      end;
      if not FileExistsUTF8(FFlagsPath + ImageName) then exit;
    end;

    fs:=nil;
    pic:=TPicture.Create;
    try
      fs:=TFileStreamUTF8.Create(FFlagsPath + ImageName, fmOpenRead or fmShareDenyWrite);
      pic.LoadFromStream(fs);
      if imgFlags.Count = 1 then begin
        imgFlags.Width:=pic.Width;
        imgFlags.Height:=pic.Height;
      end;
      Result:=imgFlags.AddMasked(pic.Bitmap, clNone);
    finally
      pic.Free;
      fs.Free;
    end;
  except
  end;
end;

procedure TMainForm.BeforeCloseApp;
begin
  if WindowState = wsNormal then begin
    Ini.WriteInteger('MainForm', 'Left', Left);
    Ini.WriteInteger('MainForm', 'Top', Top);
    Ini.WriteInteger('MainForm', 'Width', Width);
    Ini.WriteInteger('MainForm', 'Height', Height);
  end;
  if WindowState <> wsMinimized then
    Ini.WriteInteger('MainForm', 'State', integer(WindowState));

  if VSplitter.Visible then
    Ini.WriteInteger('MainForm', 'VSplitter', VSplitter.GetSplitterPosition);
  if HSplitter.Visible then
    Ini.WriteInteger('MainForm', 'HSplitter', HSplitter.GetSplitterPosition);

  Ini.WriteBool('MainForm', 'FilterPane', acFilterPane.Checked);
  Ini.WriteBool('MainForm', 'InfoPane', acInfoPane.Checked);
  Ini.WriteBool('MainForm', 'StatusBar', acStatusBar.Checked);

  Ini.WriteBool('MainForm', 'Menu', acMenuShow.Checked);
  Ini.WriteBool('MainForm', 'Toolbar', acToolbarShow.Checked);


  SaveColumns(gTorrents, 'TorrentsList');
  SaveColumns(lvFiles, 'FilesList');
  SaveColumns(lvPeers, 'PeerList');
  SaveColumns(lvTrackers, 'TrackersList');

  Ini.WriteBool('PeersList', 'ResolveHost', acResolveHost.Checked);
  Ini.WriteBool('PeersList', 'ResolveCountry', acResolveCountry.Checked);
  Ini.WriteBool('PeersList', 'ShowCountryFlag', acShowCountryFlag.Checked);

  if RpcObj.Connected then
    Ini.WriteInteger('Interface', 'LastRpcVersion', RpcObj.RPCVersion);

  try
    Ini.UpdateFile;
  except
    Application.HandleException(nil);
  end;

  DoDisconnect;
  Application.ProcessMessages;
end;

function TMainForm.GetGeoIpDatabase: string;
begin
  Result:=LocateFile('GeoIP.dat', [FHomeDir, ExtractFilePath(ParamStrUTF8(0))]);
end;

function TMainForm.GetFlagsArchive: string;
begin
  Result:=LocateFile('flags.zip', [FHomeDir, ExtractFilePath(ParamStrUTF8(0))]);
end;

function TMainForm.DownloadGeoIpDatabase(AUpdate: boolean): boolean;
const
  GeoLiteURL = 'https://dl.miyuru.lk/geoip/maxmind/country/maxmind4.dat.gz';
var
  tmp: string;
  gz: TGZFileStream;
  fs: TFileStreamUTF8;
  buf: array[0..65535] of byte;
  i: integer;
begin
  Result:=False;
  tmp:=SysToUTF8(GetTempDir(True)) + 'GeoIP.dat.gz';
  if not FileExistsUTF8(tmp) or AUpdate then begin
    if MessageDlg('', sGeoIPConfirm, mtConfirmation, mbYesNo, 0, mbYes) <> mrYes then
      exit;
    if not DownloadFile(GeoLiteURL, ExtractFilePath(tmp), ExtractFileName(tmp)) then
      exit;
  end;
  try
    FreeAndNil(FResolver);
    gz:=TGZFileStream.Create(tmp, gzopenread);
    try
      fs:=TFileStreamUTF8.Create(FHomeDir + 'GeoIP.dat', fmCreate);
      try
        repeat
          i:=gz.read(buf, SizeOf(buf));
          fs.WriteBuffer(buf, i);
        until i < SizeOf(buf);
      finally
        fs.Free;
      end;
    finally
      gz.Free;
    end;
    DeleteFileUTF8(tmp);
  except
    DeleteFileUTF8(FHomeDir + 'GeoIP.dat');
    DeleteFileUTF8(tmp);
    raise;
  end;
  Result:=True;
end;

procedure TMainForm.TorrentColumnsChanged;
var
  i: integer;
  s: string;
begin
  s:='';
  for i:=0 to gTorrents.Columns.Count - 1 do
    with gTorrents.Columns[i] do
      if Visible and (Width > 0) then begin
        if TorrentFieldsMap[ID - 1] <> '' then begin
          if s <> '' then
            s:=s + ',';
          s:=s + TorrentFieldsMap[ID - 1];
        end;
      end;
  RpcObj.TorrentFields:=s;
  DoRefresh(True);
end;

function TMainForm.EtaToString(ETA: integer): string;
const
  r1 = 60;
  r2 = 5*60;
  r3 = 30*60;
  r4 = 60*60;

begin
  if (ETA < 0) or (ETA = MaxInt) then
    Result:=''
  else begin
    if ETA > 2*60*60 then  // > 5 hours - round to 1 hour
      ETA:=(ETA + r4 div 2) div r4 * r4
    else
    if ETA > 2*60*60 then  // > 2 hours - round to 30 mins
      ETA:=(ETA + r3 div 2) div r3 * r3
    else
    if ETA > 30*60 then  // > 30 mins - round to 5 mins
      ETA:=(ETA + r2 div 2) div r2 * r2
    else
    if ETA > 2*60 then   // > 2 mins - round to 1 min
    ETA:=(ETA + r1 div 2) div r1 * r1;
    Result:=SecondsToString(ETA);
  end;
end;

function TMainForm.GetTorrentStatus(TorrentIdx: integer): string;
var
  i: integer;
begin
  i:=gTorrents.Items[idxStatus, TorrentIdx];
  if i = TR_STATUS_CHECK_WAIT then
    Result:=sWaiting
  else
  if i = TR_STATUS_CHECK then
    Result:=sVerifying
  else
  if i = TR_STATUS_DOWNLOAD_WAIT then
    Result:=sWaiting
  else
  if i = TR_STATUS_DOWNLOAD then
    Result:=sDownloading
  else
  if i = TR_STATUS_SEED_WAIT then
    Result:=sWaiting
  else
  if i = TR_STATUS_SEED then
    Result:=sSeeding
  else
  if i = TR_STATUS_STOPPED then
    Result:=sStopped
  else
  if i = TR_STATUS_FINISHED then
    Result:=sFinished
  else
    Result:=sUnknown;
end;

function TMainForm.GetSeedsText(Seeds, SeedsTotal: integer): string;
begin
  if SeedsTotal <> -1 then
    Result:=Format('%d/%d', [Seeds, SeedsTotal])
  else
    Result:=Format('%d', [Seeds]);
end;

function TMainForm.GetPeersText(Peers, PeersTotal, Leechers: integer): string;
begin
  Result:=Format('%d', [Peers]);
  if Leechers <> -1 then
    Result:=Format('%s/%d', [Result, Leechers]);
  Dec(PeersTotal);
  if PeersTotal >= 0 then
    Result:=Format('%s (%d)', [Result, PeersTotal]);
end;

function TMainForm.RatioToString(Ratio: double): string;
begin
  if (Ratio = MaxInt) or (Ratio = -2) then
    Result:=Utf8Encode(WideString(WideChar($221E)))
  else
    if Ratio = -1 then
      Result:=''
    else
      Result:=Format('%.3f', [Ratio]);
end;

function HumanReadableTime(ANow,AThen: TDateTime): string;
var
  Years, Months, Days, Hours, Minutes, Seconds, Discard: Word;
begin
  Try
    PeriodBetween(ANow,AThen,Years,Months,Days);
    if Sign(Anow-Athen)*CompareTime(Anow,Athen) < 0 then Dec(Days);
    DecodeDateTime(Sign(Anow-Athen)*(Anow-AThen),discard,Discard,Discard,Hours,Minutes,Seconds,Discard);
    if Years > 0 then begin
      Result := Format(sYears,[Years]) + ' ' + Format(sMonths,[Months]);
    end else if Months > 0 then begin
      Result := Format(sMonths,[Months]) + ' ' + Format(sDays,[Days]);
    end else if Days > 0 then begin
      Result := Format(sDays,[Days]) + ' ' + Format(sHours,[Hours]);
    end else if Hours > 0 then begin
      Result := Format(sHours,[Hours]) + ' ' + Format(sMins,[Minutes]);
    end else if Minutes > 0 then begin
      Result := Format(sMins,[Minutes]) + ' ' + Format(sSecs,[Seconds]);
    end else begin
      Result := Format(sSecs,[Seconds])
    end;
  Except
    Result := 'An Eternity';
  End;
end;

function TMainForm.TorrentDateTimeToString(d: Int64; FromNow: Boolean): string;
var
  s: string;
begin
  if d = 0 then
    Result:=''
  else begin
    if FromNow then
      s := HumanReadableTime(Now,UnixToDateTime(d) + GetTimeZoneDelta)
    else
      s := DateTimeToStr(UnixToDateTime(d) + GetTimeZoneDelta);
    Result := s;
  end;
end;

procedure TMainForm.DoRefresh(All: boolean);
begin
  if All then
    RpcObj.RefreshNow:=RpcObj.RefreshNow + [rtTorrents, rtDetails]
  else
    RpcObj.RefreshNow:=RpcObj.RefreshNow + [rtDetails];
end;

procedure TMainForm.acDisconnectExecute(Sender: TObject);
begin
  DoDisconnect;
end;

procedure TMainForm.acExportExecute(Sender: TObject); // PETROV
var
  s,d : string;
  FileVar1: TextFile;
  FileVar2: TextFile;
begin
  SaveDialog1.filename := 'transgui.ini';
  if SaveDialog1.Execute then begin
    s:=SaveDialog1.filename;
    d:=Ini.getFileName();

    AssignFile(FileVar1, d );
    AssignFile(FileVar2, s );

    Reset  (FileVar1);
    Rewrite(FileVar2);

    {$I+} //use exceptions
    try

    Repeat
      Readln (FileVar1,s);
      Writeln(FileVar2,s);
    Until Eof(FileVar1);

    CloseFile(FileVar1);
    CloseFile(FileVar2);
    except
    end;
    {$I-} //!use exceptions
  end;
end;

procedure TMainForm.acImportExecute(Sender: TObject);
var
  s,d : string;
  FileVar1: TextFile;
  FileVar2: TextFile;
  P,p1,p2,p3,p4: Integer;
begin
  OpenDialog1.filename := 'transgui.ini';
  if OpenDialog1.Execute then begin
    s:=OpenDialog1.filename;
    d:=Ini.getFileName();
    p1:=0;
    p2:=0;
    p3:=0;
    p4:=0;
    // check valid Ini-file
    AssignFile(FileVar2, s);
    Reset     (FileVar2);
    {$I+} //use exceptions
    try
    Repeat
      Readln (FileVar2,s);
      P := Pos ('[Hosts]',s);
      if P>0 then p1 := P;

      P := Pos ('[MainForm]',s);
      if P>0 then p2 := P;

      P := Pos ('[TorrentsList]',s);
      if P>0 then p3 := P;

      P := Pos ('ShowCountryFlag=',s);
      if P>0 then p4 := P;
    Until Eof(FileVar2);
    CloseFile(FileVar2);
    except
    end;
    {$I-} //!use exceptions

    if (p1=0) and (p2=0) and (p3=0) and (p4=0) then begin
        MessageDlg('Invalid file!', mtError, [mbOK], 0);
        exit;
    end;

    // rewrite ini-file
    s:=OpenDialog1.filename;
    AssignFile(FileVar1, s );
    AssignFile(FileVar2, d );

    Reset  (FileVar1);
    Rewrite(FileVar2);

    {$I+} //use exceptions
    try
    Repeat
      Readln (FileVar1,s);
      Writeln(FileVar2,s);
    Until Eof(FileVar1);
    CloseFile(FileVar1);
    CloseFile(FileVar2);
    except
    end;
    {$I-} //!use exceptions

    // Read ini now!
    CheckAppParams ();
    MessageDlg(sRestartRequired, mtInformation, [mbOk], 0);
  end;
end;

procedure TMainForm.acExitExecute(Sender: TObject);
begin
  BeforeCloseApp;
  Application.Terminate;
end;

procedure TMainForm.acDaemonOptionsExecute(Sender: TObject);
var
  req, args: TJSONObject;
  s: string;
  i, j: integer;
begin
  with TDaemonOptionsForm.Create(Self) do
  try
    AppBusy;
    req:=TJSONObject.Create;
    try
      req.Add('method', 'session-get');
      args:=RpcObj.SendRequest(req);
      if args <> nil then
        try
          edDownloadDir.Text:= CorrectPath(UTF8Encode(args.Strings['download-dir']));
          if RpcObj.RPCVersion >= 5 then begin
            // RPC version 5
            edPort.Value:=args.Integers['peer-port'];
            cbPEX.Checked:=args.Integers['pex-enabled'] <> 0;
            edMaxPeers.Value:=args.Integers['peer-limit-global'];
            cbRandomPort.Checked:=args.Integers['peer-port-random-on-start'] <> 0;
            cbDHT.Checked:=args.Integers['dht-enabled'] <> 0;
            cbSeedRatio.Checked:=args.Integers['seedRatioLimited'] <> 0;
            edSeedRatio.Value:=args.Floats['seedRatioLimit'];
            cbBlocklist.Checked:=args.Integers['blocklist-enabled'] <> 0;

            cbAltEnabled.Checked:=args.Integers['alt-speed-enabled'] <> 0;
            edAltDown.Value:=args.Integers['alt-speed-down'];
            edAltUp.Value:=args.Integers['alt-speed-up'];
            cbAutoAlt.Checked:=args.Integers['alt-speed-time-enabled'] <> 0;
            edAltTimeBegin.Text:=FormatDateTime('hh:nn', args.Integers['alt-speed-time-begin']/MinsPerDay);
            edAltTimeEnd.Text:=FormatDateTime('hh:nn', args.Integers['alt-speed-time-end']/MinsPerDay);
            j:=args.Integers['alt-speed-time-day'];
            for i:=1 to 7 do begin
              TCheckBox(gbAltSpeed.FindChildControl(Format('cbDay%d', [i]))).Checked:=LongBool(j and 1);
              j:=j shr 1;
            end;
            cbAutoAltClick(nil);
          end
          else begin
            // RPC versions prior to v5
            cbPortForwarding.Top:=cbRandomPort.Top;
            edPort.Value:=args.Integers['port'];
            cbPEX.Checked:=args.Integers['pex-allowed'] <> 0;
            edMaxPeers.Value:=args.Integers['peer-limit'];
            cbRandomPort.Visible:=False;
            cbDHT.Visible:=False;
            cbSeedRatio.Visible:=False;
            edSeedRatio.Visible:=False;
            btTestPort.Visible:=False;
            cbBlocklist.Visible:=False;
            gbAltSpeed.Visible:=False;
          end;

          if RpcObj.RPCVersion >= 7 then begin
            cbIncompleteDir.Checked:=args.Integers['incomplete-dir-enabled'] <> 0;
            edIncompleteDir.Text:=UTF8Encode(args.Strings['incomplete-dir']);
            cbIncompleteDirClick(nil);
          end
          else begin
            cbIncompleteDir.Visible:=False;
            edIncompleteDir.Visible:=False;
          end;

          if RpcObj.RPCVersion >= 8 then
            cbPartExt.Checked:=args.Integers['rename-partial-files'] <> 0
          else
            cbPartExt.Visible:=False;

          if RpcObj.RPCVersion >= 9 then
            cbLPD.Checked:=args.Integers['lpd-enabled'] <> 0
          else
            cbLPD.Visible:=False;

          if RpcObj.RPCVersion >= 10 then begin
            edCacheSize.Value:=args.Integers['cache-size-mb'];
            cbIdleSeedLimit.Checked:=args.Integers['idle-seeding-limit-enabled'] <> 0;
            edIdleSeedLimit.Value:=args.Integers['idle-seeding-limit'];
            cbIdleSeedLimitClick(nil);
          end
          else begin
            edCacheSize.Visible:=False;
            txCacheSize.Visible:=False;
            txMB.Visible:=False;
            cbIdleSeedLimit.Visible:=False;
            edIdleSeedLimit.Visible:=False;
            txMinutes.Visible:=False;
          end;

          if args.IndexOfName('blocklist-url') >= 0 then
            edBlocklistURL.Text:=UTF8Encode(args.Strings['blocklist-url'])
          else begin
            edBlocklistURL.Visible:=False;
            cbBlocklist.Left:=cbPEX.Left;
            cbBlocklist.Caption:=StringReplace(cbBlocklist.Caption, ':', '', [rfReplaceAll]);
          end;
          cbBlocklistClick(nil);

          if RpcObj.RPCVersion >= 13 then
            cbUTP.Checked:=args.Integers['utp-enabled'] <> 0
          else
            cbUTP.Visible:=False;

          if RpcObj.RPCVersion >= 14 then begin
            tabQueue.TabVisible:=True;
            cbDownQueue.Checked:=args.Integers['download-queue-enabled'] <> 0;
            edDownQueue.Value:=args.Integers['download-queue-size'];
            cbUpQueue.Checked:=args.Integers['seed-queue-enabled'] <> 0;
            edUpQueue.Value:=args.Integers['seed-queue-size'];
            cbStalled.Checked:=args.Integers['queue-stalled-enabled'] <> 0;
            edStalledTime.Value:=args.Integers['queue-stalled-minutes'];
          end
          else
            tabQueue.TabVisible:=False;

          cbPortForwarding.Checked:=args.Integers['port-forwarding-enabled'] <> 0;
          s:=args.Strings['encryption'];
          if s = 'preferred' then
            cbEncryption.ItemIndex:=1
          else
          if s = 'required' then
            cbEncryption.ItemIndex:=2
          else
            cbEncryption.ItemIndex:=0;
          cbMaxDown.Checked:=args.Integers['speed-limit-down-enabled'] <> 0;
          edMaxDown.Value:=args.Integers['speed-limit-down'];
          cbMaxUp.Checked:=args.Integers['speed-limit-up-enabled'] <> 0;
          edMaxUp.Value:=args.Integers['speed-limit-up'];
        finally
          args.Free;
        end
      else begin
        CheckStatus(False);
        exit;
      end;
    finally
      req.Free;
    end;
    cbMaxDownClick(nil);
    cbMaxUpClick(nil);
    cbRandomPortClick(nil);
    cbSeedRatioClick(nil);
    AppNormal;

    if ShowModal = mrOK then begin
      AppBusy;
      Self.Update;
      req:=TJSONObject.Create;
      try
        req.Add('method', 'session-set');
        args:=TJSONObject.Create;
        args.Add('download-dir', UTF8Decode(edDownloadDir.Text));
        args.Add('port-forwarding-enabled', integer(cbPortForwarding.Checked) and 1);
        case cbEncryption.ItemIndex of
          1: s:='preferred';
          2: s:='required';
          else s:='tolerated';
        end;
        args.Add('encryption', s);
        args.Add('speed-limit-down-enabled', integer(cbMaxDown.Checked) and 1);
        if cbMaxDown.Checked then
          args.Add('speed-limit-down', edMaxDown.Value);
        args.Add('speed-limit-up-enabled', integer(cbMaxUp.Checked) and 1);
        if cbMaxUp.Checked then
          args.Add('speed-limit-up', edMaxUp.Value);
        if RpcObj.RPCVersion >= 5 then begin
          args.Add('peer-limit-global', edMaxPeers.Value);
          args.Add('peer-port', edPort.Value);
          args.Add('pex-enabled', integer(cbPEX.Checked) and 1);
          args.Add('peer-port-random-on-start', integer(cbRandomPort.Checked) and 1);
          args.Add('dht-enabled', integer(cbDHT.Checked) and 1);
          args.Add('seedRatioLimited', integer(cbSeedRatio.Checked) and 1);
          if cbSeedRatio.Checked then
            args.Add('seedRatioLimit', edSeedRatio.Value);
          args.Add('blocklist-enabled', integer(cbBlocklist.Checked) and 1);

          args.Add('alt-speed-enabled', integer(cbAltEnabled.Checked) and 1);
          args.Add('alt-speed-down', edAltDown.Value);
          args.Add('alt-speed-up', edAltUp.Value);
          args.Add('alt-speed-time-enabled', integer(cbAutoAlt.Checked) and 1);
          if cbAutoAlt.Checked then begin
            args.Add('alt-speed-time-begin', Round(Frac(StrToTime(edAltTimeBegin.Text))*MinsPerDay));
            args.Add('alt-speed-time-end', Round(Frac(StrToTime(edAltTimeEnd.Text))*MinsPerDay));
            j:=0;
            for i:=7 downto 1 do begin
              j:=j shl 1;
              j:=j or (integer(TCheckBox(gbAltSpeed.FindChildControl(Format('cbDay%d', [i]))).Checked) and 1);
            end;
            args.Add('alt-speed-time-day', j);
          end;
        end
        else begin
          args.Add('peer-limit', edMaxPeers.Value);
          args.Add('port', edPort.Value);
          args.Add('pex-allowed', integer(cbPEX.Checked) and 1);
        end;
        if RpcObj.RPCVersion >= 7 then begin
          args.Add('incomplete-dir-enabled', integer(cbIncompleteDir.Checked) and 1);
          if cbIncompleteDir.Checked then
            args.Add('incomplete-dir', UTF8Decode(edIncompleteDir.Text));
        end;
        if RpcObj.RPCVersion >= 8 then
          args.Add('rename-partial-files', integer(cbPartExt.Checked) and 1);
        if RpcObj.RPCVersion >= 9 then
          args.Add('lpd-enabled', integer(cbLPD.Checked) and 1);
        if RpcObj.RPCVersion >= 10 then begin
          args.Add('cache-size-mb', edCacheSize.Value);
          args.Add('idle-seeding-limit-enabled', integer(cbIdleSeedLimit.Checked) and 1);
          args.Add('idle-seeding-limit', edIdleSeedLimit.Value);
        end;
        if edBlocklistURL.Visible then
          if cbBlocklist.Checked then
            args.Add('blocklist-url', UTF8Decode(edBlocklistURL.Text));
        if RpcObj.RPCVersion >= 13 then
          args.Add('utp-enabled', integer(cbUTP.Checked) and 1);
        if RpcObj.RPCVersion >= 14 then begin
          args.Add('download-queue-enabled', integer(cbDownQueue.Checked) and 1);
          args.Add('download-queue-size', edDownQueue.Value);
          args.Add('seed-queue-enabled', integer(cbUpQueue.Checked) and 1);
          args.Add('seed-queue-size', edUpQueue.Value);
          args.Add('queue-stalled-enabled', integer(cbStalled.Checked) and 1);
          args.Add('queue-stalled-minutes', edStalledTime.Value);
        end;

        req.Add('arguments', args);
        args:=RpcObj.SendRequest(req, False);
        if args = nil then begin
          CheckStatus(False);
          exit;
        end;
        args.Free;
      finally
        req.Free;
      end;
      RpcObj.RefreshNow:=RpcObj.RefreshNow + [rtSession];
      AppNormal;
    end;
  finally
    Free;
  end;
end;

procedure TMainForm.acQMoveBottomExecute(Sender: TObject);
begin
  TorrentAction(GetSelectedTorrents, 'queue-move-bottom');
end;

procedure TMainForm.acQMoveDownExecute(Sender: TObject);
begin
  TorrentAction(GetSelectedTorrents, 'queue-move-down');
end;

procedure TMainForm.acQMoveTopExecute(Sender: TObject);
begin
  TorrentAction(GetSelectedTorrents, 'queue-move-top');
end;

procedure TMainForm.acQMoveUpExecute(Sender: TObject);
begin
  TorrentAction(GetSelectedTorrents, 'queue-move-up');
end;

procedure TMainForm.acReannounceTorrentExecute(Sender: TObject);
begin
  TorrentAction(GetSelectedTorrents, 'torrent-reannounce');
end;

procedure TMainForm.acRemoveTorrentAndDataExecute(Sender: TObject);
begin
  InternalRemoveTorrent(sRemoveTorrentData, sRemoveTorrentDataMulti, True);
end;

procedure TMainForm.acRemoveTorrentExecute(Sender: TObject);
begin
  InternalRemoveTorrent(sRemoveTorrent, sRemoveTorrentMulti, False);
end;

procedure TMainForm.acRenameExecute(Sender: TObject);
begin
  if lvFiles.Focused then
    lvFiles.EditCell(idxFileName, lvFiles.Row)
  else
    gTorrents.EditCell(idxName, gTorrents.Row);
end;

procedure TMainForm.acResolveCountryExecute(Sender: TObject);
begin
  if not acResolveCountry.Checked then
    if GetGeoIpDatabase = '' then
      if not DownloadGeoIpDatabase(False) then
        exit;

  acResolveCountry.Checked:=not acResolveCountry.Checked;
  FreeAndNil(FResolver);
  DoRefresh;
  acShowCountryFlag.Enabled:=acResolveCountry.Checked;
end;

procedure TMainForm.acResolveHostExecute(Sender: TObject);
begin
  acResolveHost.Checked:=not acResolveHost.Checked;
  FreeAndNil(FResolver);
  DoRefresh;
end;

procedure TMainForm.acSelectAllExecute(Sender: TObject);
begin
  Application.ProcessMessages;
  if lvFiles.Focused then
    lvFiles.SelectAll
  else
    gTorrents.SelectAll;
end;

procedure TMainForm.acSetHighPriorityExecute(Sender: TObject);
begin
  Application.ProcessMessages;
  if lvFiles.Focused then
    SetCurrentFilePriority('high')
  else
    SetTorrentPriority(TR_PRI_HIGH);
end;

procedure TMainForm.acSetLowPriorityExecute(Sender: TObject);
begin
  Application.ProcessMessages;
  if lvFiles.Focused then
    SetCurrentFilePriority('low')
  else
    SetTorrentPriority(TR_PRI_LOW);
end;

procedure TMainForm.acSetNormalPriorityExecute(Sender: TObject);
begin
  Application.ProcessMessages;
  if lvFiles.Focused then
    SetCurrentFilePriority('normal')
  else
    SetTorrentPriority(TR_PRI_NORMAL);
end;

procedure TMainForm.acSetNotDownloadExecute(Sender: TObject);
begin
  SetCurrentFilePriority('skip');
end;

procedure TMainForm.acSetLabelsExecute(Sender: TObject);
var
  ids: variant;
  i: integer;
  input, s: string;
  req: TJSONObject;
  aids: TJSONArray;
  alabels: TJSONArray;
  slabels: TStringList;
  args: TJSONObject;
begin
  if gTorrents.Items.Count = 0 then
    exit;
  gTorrents.Tag:=1;
  gTorrents.EnsureSelectionVisible;
  if gTorrents.SelCount = 0 then
    gTorrents.RowSelected[gTorrents.Row]:=True;
  ids:=GetSelectedTorrents;
  i:=gTorrents.Items.IndexOf(idxTorrentId, ids[0]);
  if VarIsEmpty(gTorrents.Items[idxPath, i]) then
    exit;
  if InputQuery('Set tags',
      'This will overwrite any existing tags.' + sLineBreak +
      'You can set multiple tags separated by a comma or leave empty to clear tags.',
      input) then begin
    AppBusy;
    req := TJSONObject.Create;
    args := TJSONObject.Create;
    aids := TJSONArray.Create;
    alabels := TJSONArray.Create;
    slabels := TStringList.Create;
    try
      req.Add('method', 'torrent-set');
      for i:=VarArrayLowBound(ids, 1) to VarArrayHighBound(ids, 1) do
            aids.Add(integer(ids[i]));
      args.Add('ids', aids);
      SplitRegExpr(',', input, slabels);
      slabels.Sort;
      for s in slabels do begin
        alabels.Add(trim(s));
      end;
      args.Add('labels', alabels);
      req.Add('arguments', args);
      args := RpcObj.SendRequest(req, False);
      args.Free;
    finally
      req.Free;
      AppNormal;
    end;
    if args = nil then
      CheckStatus(False)
    else begin
      RpcObj.RequestFullInfo:=True;
      DoRefresh(True);
      Sleep(200);
      Application.ProcessMessages;
    end;

  end;
  gTorrents.Tag:=0;
end;

procedure TMainForm.acSetupColumnsExecute(Sender: TObject);
var
  g: TVarGrid;
  s: string;
begin
  Application.ProcessMessages;
  if lvTrackers.Focused then
    g:=lvTrackers
  else
  if lvPeers.Focused then
    g:=lvPeers
  else
  if lvFiles.Focused then
    g:=lvFiles
  else
    g:=gTorrents;
  if g = gTorrents then
    s:=sTorrents
  else
    if PageInfo.ActivePage = tabFiles then
      s:=FFilesCapt
    else
      s:=PageInfo.ActivePage.Caption;
  if not SetupColumns(g, 0, s) then exit;
  if g = gTorrents then
    TorrentColumnsChanged;
end;

procedure TMainForm.acShowAppExecute(Sender: TObject);
begin
  ShowApp;
end;

procedure TMainForm.acShowCountryFlagExecute(Sender: TObject);
const
  FlagsURL = 'https://raw.githubusercontent.com/transmission-remote-gui/transgui/master/flags.zip';
begin
  if not acShowCountryFlag.Checked then
    if GetFlagsArchive = '' then begin
      if MessageDlg('', sFlagArchiveConfirm, mtConfirmation, mbYesNo, 0, mbYes) <> mrYes then
        exit;
      if not DownloadFile(FlagsURL, FHomeDir) then
        exit;
    end;
  acShowCountryFlag.Checked:=not acShowCountryFlag.Checked;
  DoRefresh;
end;

procedure TMainForm.acStartAllTorrentsExecute(Sender: TObject);
begin
  TorrentAction(NULL, 'torrent-start');
end;

procedure TMainForm.acStartTorrentExecute(Sender: TObject);
begin
  TorrentAction(GetSelectedTorrents, 'torrent-start');
end;

procedure TMainForm.acStatusBarExecute(Sender: TObject);
begin
  acStatusBar.Checked:=not acStatusBar.Checked;
  StatusBar.Visible:=acStatusBar.Checked;
  if StatusBar.Visible then
      StatusBar.Top:=ClientHeight
  else
    begin
      acStatusBarSizes.Checked := true;
      acStatusBarSizesExecute(nil);
    end;
end;

procedure TMainForm.acStatusBarSizesExecute(Sender: TObject);
begin
  acStatusBarSizes.Checked := not acStatusBarSizes.Checked;
  if acStatusBarSizes.Checked then
    begin
      acStatusBar.Checked:=false;
      acStatusBarExecute(nil);
    end
      else
        begin
          StatusBar.Panels[4].Text:= '';
          StatusBar.Panels[5].Text:= '';
          StatusBar.Panels[6].Text:= '';
          StatusBar.Panels[7].Text:= '';
        end;
        Ini.WriteBool('MainForm','StatusBarSizes',acStatusBarSizes.Checked);
end;

procedure TMainForm.acStopAllTorrentsExecute(Sender: TObject);
begin
  TorrentAction(NULL, 'torrent-stop');
end;

procedure TMainForm.acStopTorrentExecute(Sender: TObject);
begin
  TorrentAction(GetSelectedTorrents, 'torrent-stop');
end;

procedure TMainForm.gTorrentsMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var r, c, ADatacol: integer;
begin
  ADataCol := 0;
  gTorrents.MouseToCell(x, y, c, r);
  if c>= 0 then ADataCol := gTorrents.ColToDataCol(c);
  if r = 0 then gTorrents.Hint:='';
  if (ADataCol <> FCol) or (r <> FRow) then
    begin
      FCol := ADataCol;
      FRow := r;
      case ADataCol of
      idxAddedOn, idxCompletedOn, idxLastActive:
        begin
          Application.CancelHint;
          gTorrents.Hint := TorrentDateTimeToString(gTorrents.Items[ADataCol, FRow-1],not(FFromNow));
        end
        else gTorrents.Hint:='';
      end;
    end;
end;

procedure TMainForm.gTorrentsMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbRight then pmTorrents.PopUp;
end;

procedure TMainForm.LocalWatchTimerTimer(Sender: TObject);
begin
  ReadLocalFolderWatch;
  if FPendingTorrents.Count > 0 then
    begin
      FWatchDownloading := true;
      TickTimerTimer(nil);
    end;
end;


procedure TMainForm.lvFilesMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbRight then pmFiles.PopUp;
end;

procedure TMainForm.MenuShowExecute(Sender: TObject);
begin
  acMenuShow.Checked:=not acMenuShow.Checked;
  if acMenuShow.Checked = false then
    MainForm.Menu := nil
  else
    MainForm.Menu := MainMenu;
end;

procedure TMainForm.acToolbarShowExecute(Sender: TObject);
begin
  acToolbarShow.Checked:=not acToolbarShow.Checked;
  if acToolbarShow.Checked = false then
    MainToolBar.Visible:= false
  else
    MainToolBar.Visible:= true;
end;

procedure TMainForm.acTorrentPropsExecute(Sender: TObject);
begin
  TorrentProps(0);
end;

procedure TMainForm.TorrentProps(PageNo: integer);
const
  TR_RATIOLIMIT_GLOBAL    = 0; // follow the global settings
  TR_RATIOLIMIT_SINGLE    = 1; // override the global settings, seeding until a certain ratio
  TR_RATIOLIMIT_UNLIMITED = 2; // override the global settings, seeding regardless of ratio

  TR_IDLELIMIT_GLOBAL     = 0; // follow the global settings
  TR_IDLELIMIT_SINGLE     = 1; // override the global settings, seeding until a certain idle time
  TR_IDLELIMIT_UNLIMITED  = 2; // override the global settings, seeding regardless of activity

var
  req, args, t, tr: TJSONObject;
  i, j, id: integer;
  ids, Trackers, AddT, EditT, DelT: TJSONArray;
  TorrentIds: variant;
  s: string;
  trlist, sl: TStringList;
begin
  gTorrentsClick(nil);
  id:=RpcObj.CurTorrentId;
  if id = 0 then exit;
  AppBusy;
  trlist:=nil;
  with TTorrPropsForm.Create(Self) do
  try
    Page.ActivePageIndex:=PageNo;
    gTorrents.Tag:=1;
    gTorrents.EnsureSelectionVisible;
    TorrentIds:=GetSelectedTorrents;
    args:=RpcObj.RequestInfo(id, ['downloadLimit', 'downloadLimitMode', 'downloadLimited', 'uploadLimit', 'uploadLimitMode', 'uploadLimited',
                                  'name', 'maxConnectedPeers', 'seedRatioMode', 'seedRatioLimit', 'seedIdleLimit', 'seedIdleMode', 'trackers']);
    if args = nil then begin
      CheckStatus(False);
      exit;
    end;
    try
      t:=args.Arrays['torrents'].Objects[0];

      if gTorrents.SelCount > 1 then
        s:=Format(sSeveralTorrents, [gTorrents.SelCount])
      else
        s:=UTF8Encode(t.Strings['name']);

      txName.Caption:=txName.Caption + ' ' + s;
      Caption:=Caption + ' - ' + s;
      if RpcObj.RPCVersion < 5 then begin
        // RPC versions prior to v5
        j:=t.Integers['downloadLimitMode'];
        cbMaxDown.Checked:=j = TR_SPEEDLIMIT_SINGLE;
        i:=t.Integers['downloadLimit'];
        if (i < 0) or (j = TR_SPEEDLIMIT_UNLIMITED) then
          edMaxDown.ValueEmpty:=True
        else
          edMaxDown.Value:=i;

        j:=t.Integers['uploadLimitMode'];
        cbMaxUp.Checked:=j = TR_SPEEDLIMIT_SINGLE;
        i:=t.Integers['uploadLimit'];
        if (i < 0) or (j = TR_SPEEDLIMIT_UNLIMITED) then
          edMaxUp.ValueEmpty:=True
        else
          edMaxUp.Value:=i;
        cbSeedRatio.Visible:=False;
        edSeedRatio.Visible:=False;
      end else begin
        // RPC version 5
        cbMaxDown.Checked:=t.Booleans['downloadLimited'];
        i:=t.Integers['downloadLimit'];
        if i < 0 then
          edMaxDown.ValueEmpty:=True
        else
          edMaxDown.Value:=i;

        cbMaxUp.Checked:=t.Booleans['uploadLimited'];
        i:=t.Integers['uploadLimit'];
        if i < 0 then
          edMaxUp.ValueEmpty:=True
        else
          edMaxUp.Value:=i;

        case t.Integers['seedRatioMode'] of
          TR_RATIOLIMIT_SINGLE:
            cbSeedRatio.State:=cbChecked;
          TR_RATIOLIMIT_UNLIMITED:
            cbSeedRatio.State:=cbUnchecked;
          else
            cbSeedRatio.State:=cbGrayed;
        end;
        edSeedRatio.Value:=t.Floats['seedRatioLimit'];
      end;

      if RpcObj.RPCVersion >= 10 then begin
        case t.Integers['seedIdleMode'] of
          TR_IDLELIMIT_SINGLE:
            cbIdleSeedLimit.State:=cbChecked;
          TR_IDLELIMIT_UNLIMITED:
            cbIdleSeedLimit.State:=cbUnchecked;
          else
            cbIdleSeedLimit.State:=cbGrayed;
        end;
        edIdleSeedLimit.Value:=t.Integers['seedIdleLimit'];
        cbIdleSeedLimitClick(nil);

        trlist:=TStringList.Create;
        Trackers:=t.Arrays['trackers'];
        for i:=0 to Trackers.Count - 1 do begin
          tr:=Trackers[i] as TJSONObject;
            trlist.AddObject(UTF8Decode(tr.Strings['announce']), TObject(PtrUInt(tr.Integers['id'])));
        end;
        edTrackers.Lines.Assign(trlist);
      end
      else begin
        cbIdleSeedLimit.Visible:=False;
        edIdleSeedLimit.Visible:=False;
        txMinutes.Visible:=False;
        tabAdvanced.TabVisible:=False;
      end;
      edPeerLimit.Value:=t.Integers['maxConnectedPeers'];
    finally
      args.Free;
    end;
    cbMaxDownClick(nil);
    cbMaxUpClick(nil);
    cbSeedRatioClick(nil);
    AppNormal;
    if ShowModal = mrOk then begin
      AppBusy;
      Self.Update;
      req:=TJSONObject.Create;
      try
        req.Add('method', 'torrent-set');
        args:=TJSONObject.Create;
        ids:=TJSONArray.Create;
        for i:=VarArrayLowBound(TorrentIds, 1) to VarArrayHighBound(TorrentIds, 1) do
          ids.Add(integer(TorrentIds[i]));
        args.Add('ids', ids);

        if RpcObj.RPCVersion < 5 then
        begin
          // RPC versions prior to v5
          args.Add('speed-limit-down-enabled', integer(cbMaxDown.Checked) and 1);
          args.Add('speed-limit-up-enabled', integer(cbMaxUp.Checked) and 1);
          if cbMaxDown.Checked then
            args.Add('speed-limit-down', edMaxDown.Value);
          if cbMaxUp.Checked then
            args.Add('speed-limit-up', edMaxUp.Value);
        end else begin
          // RPC version 5
          args.Add('downloadLimited', integer(cbMaxDown.Checked) and 1);
          args.Add('uploadLimited', integer(cbMaxUp.Checked) and 1);
          if cbMaxDown.Checked then
            args.Add('downloadLimit', edMaxDown.Value);
          if cbMaxUp.Checked then
            args.Add('uploadLimit', edMaxUp.Value);
          case cbSeedRatio.State of
            cbChecked:
              i:=TR_RATIOLIMIT_SINGLE;
            cbUnchecked:
              i:=TR_RATIOLIMIT_UNLIMITED;
            else
              i:=TR_RATIOLIMIT_GLOBAL;
          end;
          args.Add('seedRatioMode', i);
          if cbSeedRatio.State = cbChecked then
            args.Add('seedRatioLimit', edSeedRatio.Value);
        end;

        if RpcObj.RPCVersion >= 10 then begin
          case cbIdleSeedLimit.State of
            cbChecked:
              i:=TR_IDLELIMIT_SINGLE;
            cbUnchecked:
              i:=TR_IDLELIMIT_UNLIMITED;
            else
              i:=TR_IDLELIMIT_GLOBAL;
          end;
          args.Add('seedIdleMode', i);
          if cbIdleSeedLimit.State = cbChecked then
            args.Add('seedIdleLimit', edIdleSeedLimit.Value);

          sl:=TStringList.Create;
          try
            sl.Assign(edTrackers.Lines);
            // Removing unchanged trackers
            i:=0;
            while i < sl.Count do begin
              s:=Trim(sl[i]);
              if s = '' then begin
                sl.Delete(i);
                continue;
              end;
              j:=trlist.IndexOf(s);
              if j >= 0 then begin
                trlist.Delete(j);
                sl.Delete(i);
                continue;
              end;
              Inc(i);
            end;

            AddT:=TJSONArray.Create;
            EditT:=TJSONArray.Create;
            DelT:=TJSONArray.Create;
            try
              for i:=0 to sl.Count - 1 do begin
                s:=Trim(sl[i]);
                if trlist.Count > 0 then begin
                  EditT.Add(PtrUInt(trlist.Objects[0]));
                  EditT.Add(UTF8Decode(s));
                  trlist.Delete(0);
                end
                else
                  AddT.Add(UTF8Decode(s));
              end;

              for i:=0 to trlist.Count - 1 do
                DelT.Add(PtrUInt(trlist.Objects[i]));

              if AddT.Count > 0 then begin
                args.Add('trackerAdd', AddT);
                AddT:=nil;
              end;
              if EditT.Count > 0 then begin
                args.Add('trackerReplace', EditT);
                EditT:=nil;
              end;
              if DelT.Count > 0 then begin
                args.Add('trackerRemove', DelT);
                DelT:=nil;
              end;
            finally
              DelT.Free;
              EditT.Free;
              AddT.Free;
            end;
          finally
            sl.Free;
          end;
        end;

        args.Add('peer-limit', edPeerLimit.Value);
        req.Add('arguments', args);
        args:=nil;
        args:=RpcObj.SendRequest(req, False);
        if args = nil then begin
          CheckStatus(False);
          exit;
        end;
        args.Free;
      finally
        req.Free;
      end;
      DoRefresh;
      AppNormal;
    end;
  finally
    gTorrents.Tag:=0;
    Free;
    trlist.Free;
  end;
end;

procedure TMainForm.acTrackerGroupingExecute(Sender: TObject);
begin
  acTrackerGrouping.Checked:=not acTrackerGrouping.Checked;
  Ini.WriteBool('Interface', 'TrackerGrouping', acTrackerGrouping.Checked);
  RpcObj.RefreshNow:=RpcObj.RefreshNow + [rtTorrents];
end;

procedure TMainForm.acUpdateBlocklistExecute(Sender: TObject);
var
  req: TJSONObject;
  res: TJSONObject;
begin
  Application.ProcessMessages;
  AppBusy;
  req:=TJSONObject.Create;
  try
    req.Add('method', 'blocklist-update');
    res:=RpcObj.SendRequest(req, True, 3*60000);
    AppNormal;
    if res = nil then begin
      CheckStatus(False);
      exit;
    end;
    MessageDlg(Format(sBlocklistUpdateComplete, [res.Integers[('blocklist-size')]]), mtInformation, [mbOK], 0);
    res.Free;
  finally
    req.Free;
  end;
end;

procedure TMainForm.acUpdateGeoIPExecute(Sender: TObject);
begin
  if DownloadGeoIpDatabase(True) then
    MessageDlg(sUpdateComplete, mtInformation, [mbOK], 0);
end;

procedure TMainForm.acVerifyTorrentExecute(Sender: TObject);
var
  ids: variant;
  s: string;
begin
  if gTorrents.Items.Count = 0 then exit;
  gTorrents.Tag:=1;
  try
    gTorrents.EnsureSelectionVisible;
    ids:=GetSelectedTorrents;
    if gTorrents.SelCount < 2 then
      s:=Format(sTorrentVerification, [UTF8Encode(widestring(gTorrents.Items[idxName, gTorrents.Items.IndexOf(idxTorrentId, ids[0])]))])
    else
      s:=Format(sTorrentsVerification, [gTorrents.SelCount]);
    if MessageDlg('', s, mtConfirmation, mbYesNo, 0, mbNo) <> mrYes then
      exit;
  finally
    gTorrents.Tag:=0;
  end;
  TorrentAction(ids, 'torrent-verify');
end;

procedure TMainForm.ApplicationPropertiesEndSession(Sender: TObject);
begin
  DeleteFileUTF8(FRunFileName);
  BeforeCloseApp;
end;

procedure TMainForm.ApplicationPropertiesException(Sender: TObject; E: Exception);
var
  msg: string;
{$ifdef CALLSTACK}
  sl: TStringList;
{$endif CALLSTACK}
begin
  ForceAppNormal;
  msg:=E.Message;
{$ifdef CALLSTACK}
  try
    sl:=TStringList.Create;
    try
      sl.Text:=GetLastExceptionCallStack;
      Clipboard.AsText:=msg + LineEnding + sl.Text;
      DebugLn(msg + LineEnding + sl.Text);
      if sl.Count > 20 then begin
        while sl.Count > 20 do
          sl.Delete(20);
        sl.Add('...');
      end;
      msg:=msg + LineEnding + '---' + LineEnding + 'The error details has been copied to the clipboard.' + LineEnding + '---';
      msg:=msg + LineEnding + sl.Text;
    finally
      sl.Free;
    end;
  except
    ; // suppress exception
  end;
{$endif CALLSTACK}
  MessageDlg(TranslateString(msg, True), mtError, [mbOK], 0);
end;

procedure TMainForm.ApplicationPropertiesIdle(Sender: TObject; var Done: Boolean);
begin
  UpdateUI;
{$ifdef LCLcarbon}
  CheckSynchronize;
{$endif LCLcarbon}
  Done:=True;
end;

procedure TMainForm.ApplicationPropertiesMinimize(Sender: TObject);
begin
{$ifdef CPUARM}
  exit;
{$endif  CPUARM}

{$ifndef darwin}
  if not IsUnity and Ini.ReadBool('Interface', 'TrayMinimize', True) then
    HideApp;
{$endif darwin}
  UpdateTray;
end;

procedure TMainForm.ApplicationPropertiesRestore(Sender: TObject);
begin
  UpdateTray;
  CheckClipboardLink;
end;

procedure TMainForm.edSearchChange(Sender: TObject);
begin
  DoRefresh(True);
  if edSearch.Text=  '' then tbSearchCancel.Enabled:=false
                    else tbSearchCancel.Enabled:=true;
end;

procedure TMainForm.edSearchKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
    if Key = VK_ESCAPE then edSearch.Text:='';
end;

procedure TMainForm.FormActivate(Sender: TObject);
begin
  CheckClipboardLink;
end;

procedure TMainForm.FormDropFiles(Sender: TObject; const FileNames: array of String);
var
  i: integer;
begin
  for i:=Low(FileNames) to High(FileNames) do
    AddTorrentFile(FileNames[i]);
end;

procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  Keypressed: Word;
begin
    if (Shift = [ssAlt]) and not (MainForm.ActiveControl is TVarGridStringEditor) then
    begin
      Keypressed := Key;
      Key := 0;
        case Keypressed of
          VK_S: edSearch.SetFocus;
          VK_G: PageInfo.PageIndex:=0;
          VK_K: PageInfo.PageIndex:=1;
          VK_P: PageInfo.PageIndex:=2;
          VK_F: PageInfo.PageIndex:=3;
          VK_1: lvFilter.Row:=fltAll;
          VK_2: lvFilter.Row:=fltDown;
          VK_3: lvFilter.Row:=fltDone;
          VK_4: lvFilter.Row:=fltActive;
          VK_5: lvFilter.Row:=fltInactive;
          VK_6: lvFilter.Row:=fltStopped;
          VK_7: lvFilter.Row:=fltError;
          VK_8: lvFilter.Row:=fltWaiting;
        else Key := KeyPressed;
        end;
    end;

end;

procedure TMainForm.FormWindowStateChange(Sender: TObject);
begin
{$ifdef lclgtk2}
  if WindowState = wsMinimized then
    ApplicationPropertiesMinimize(nil)
  else
    ApplicationPropertiesRestore(nil);
{$endif lclgtk2}
end;

procedure TMainForm.gTorrentsCellAttributes(Sender: TVarGrid; ACol, ARow, ADataCol: integer; AState: TGridDrawState;
                                            var CellAttribs: TCellAttributes);
var
  j: integer;
begin
  if ARow < 0 then exit;
  with CellAttribs do begin
    if ACol = gTorrents.FirstVisibleColumn then
      ImageIndex:=integer(Sender.Items[idxStateImg, ARow]);
    if Text = '' then exit;
    if not VarIsEmpty(Sender.Items[idxDeleted, ARow]) then
      with Sender.Canvas.Font do
        Style:=Style + [fsStrikeOut];
    case ADataCol of
      idxStatus:
        Text:=GetTorrentStatus(ARow);
      idxSize, idxDownloaded, idxUploaded, idxSizeToDowload, idxSizeLeft:
        Text:=GetHumanSize(Sender.Items[ADataCol, ARow], 0, '?');
      idxDone:
        Text:=Format('%.1f%%', [double(Sender.Items[idxDone, ARow])]);
      idxSeeds:
        if not VarIsNull(Sender.Items[idxSeedsTotal, ARow]) then
          Text:=GetSeedsText(Sender.Items[idxSeeds, ARow], Sender.Items[idxSeedsTotal, ARow]);
      idxPeers:
        Text:=GetPeersText(Sender.Items[idxPeers, ARow], -1, Sender.Items[idxLeechersTotal, ARow]);
      idxDownSpeed, idxUpSpeed:
        begin
          j:=Sender.Items[ADataCol, ARow];
          if j > 0 then
            Text:=GetHumanSize(j, 1) + sPerSecond
          else
            Text:='';
        end;
      idxETA:
        Text:=EtaToString(Sender.Items[idxETA, ARow]);
      idxRatio:
        Text:=RatioToString(Sender.Items[idxRatio, ARow]);
      idxAddedOn, idxCompletedOn, idxLastActive:
        Text:=TorrentDateTimeToString(Sender.Items[ADataCol, ARow],FFromNow);
      idxPriority:
        Text:=PriorityToStr(Sender.Items[ADataCol, ARow], ImageIndex);
      idxQueuePos:
        begin
          j:=Sender.Items[ADataCol, ARow];
          if j >= FinishedQueue then
            Dec(j, FinishedQueue);
          Text:=IntToStr(j);
        end;
      idxSeedingTime:
        begin
          j:=Sender.Items[idxSeedingTime, ARow];
          if j > 0 then
            Text:=EtaToString(j)
          else
            Text:='';
        end;
      idxPrivate:
        begin
          j:=Sender.Items[idxPrivate, ARow];
          if j >= 1 then
            Text:=sPrivateOn
          else
            Text:=sPrivateOff;
        end;
    end;
  end;
end;

procedure TMainForm.gTorrentsClick(Sender: TObject);
var
  i: integer;
begin
  if gTorrents.Tag <> 0 then exit;
  RpcObj.Lock;
  try
    if gTorrents.Items.Count > 0 then
      i:=gTorrents.Items[idxTorrentId, gTorrents.Row]
    else
      i:=0;
    if RpcObj.CurTorrentId = i then
      exit;
    RpcObj.CurTorrentId:=i;
  finally
    RpcObj.Unlock;
    if acStatusBarSizes.Checked then StatusBarSizes;
  end;

  ClearDetailsInfo(GetPageInfoType(PageInfo.ActivePage));

  TorrentsListTimer.Enabled:=False;
  TorrentsListTimer.Enabled:=True;
end;

procedure TMainForm.gTorrentsDblClick(Sender: TObject);
var
  res: TJSONObject;
  s, n: string;
begin
  if gTorrents.Items.Count = 0 then
    exit;
  if gTorrents.Items[idxDone, gTorrents.Row] = 100.0 then begin
    // The torrent is finished. Check if it is possible to open its file/folder
    AppBusy;
    try
      res:=RpcObj.RequestInfo(gTorrents.Items[idxTorrentId, gTorrents.Row], ['downloadDir']);
      if res = nil then
        CheckStatus(False);
      with res.Arrays['torrents'].Objects[0] do
        n:=IncludeProperTrailingPathDelimiter(UTF8Encode(Strings['downloadDir'])) + UTF8Encode(widestring(gTorrents.Items[idxName, gTorrents.Row]));
      s:=MapRemoteToLocal(n);
      if s = '' then
        s:=n;
      if FileExistsUTF8(s) or DirectoryExistsUTF8(s) then begin
        // File/folder exists - open it
        OpenCurrentTorrent(False);
        exit;
      end;
    finally
      AppNormal;
    end;
  end;
  acTorrentProps.Execute;
end;

procedure TMainForm.gTorrentsDrawCell(Sender: TVarGrid; ACol, ARow, ADataCol: integer; AState: TGridDrawState; const R: TRect; var ADefaultDrawing: boolean);
begin
  if ARow < 0 then exit;
  if ADataCol = idxDone then begin
    ADefaultDrawing:=False;
    DrawProgressCell(Sender, ACol, ARow, ADataCol, AState, R);
  end;
end;

procedure TMainForm.gTorrentsEditorHide(Sender: TObject);
begin
  gTorrents.Tag:=0;
end;

procedure TMainForm.gTorrentsEditorShow(Sender: TObject);
begin
  gTorrents.Tag:=1;
  gTorrents.RemoveSelection;
end;

procedure TMainForm.gTorrentsQuickSearch(Sender: TVarGrid; var SearchText: string; var ARow: integer);
var
  i: integer;
  s: string;
  v: variant;
begin
  s:=UTF8UpperCase(SearchText);
  for i:=ARow to gTorrents.Items.Count - 1 do begin
    v:=gTorrents.Items[idxName, i];
    if VarIsEmpty(v) or VarIsNull(v) then
      continue;
    if Pos(s, Trim(UTF8UpperCase(UTF8Encode(widestring(v))))) > 0 then begin
      ARow:=i;
      break;
    end;
  end;
end;

procedure TMainForm.gTorrentsResize(Sender: TObject);
begin
  if not FStarted then begin
    VSplitter.SetSplitterPosition(Ini.ReadInteger('MainForm', 'VSplitter', VSplitter.GetSplitterPosition));
    HSplitter.SetSplitterPosition(Ini.ReadInteger('MainForm', 'HSplitter', HSplitter.GetSplitterPosition));
  end;
end;

procedure TMainForm.gTorrentsSetEditText(Sender: TObject; ACol, ARow: Integer; const Value: string);
begin
  if RenameTorrent(gTorrents.Items[idxTorrentId, ARow], UTF8Encode(widestring(gTorrents.Items[idxName, ARow])), Trim(Value)) then begin
    gTorrents.Items[idxName, ARow]:=UTF8Decode(Trim(Value));
    FFilesTree.Clear;
  end;
end;

procedure TMainForm.gTorrentsSortColumn(Sender: TVarGrid; var ASortCol: integer);
begin
  if ASortCol = idxSeeds then
    ASortCol:=idxSeedsTotal;
  if ASortCol = idxPeers then
    ASortCol:=idxLeechersTotal;
end;

procedure TMainForm.HSplitterChangeBounds(Sender: TObject);
begin
{$ifdef windows}
  Update;
{$endif windows}
end;

procedure TMainForm.lvFilesDblClick(Sender: TObject);
begin
  acOpenFile.Execute;
end;

procedure TMainForm.lvFilesEditorHide(Sender: TObject);
begin
  gTorrents.Tag:=0;
  lvFiles.Tag:=0;
  lvFiles.HideSelection:=True;
end;

procedure TMainForm.lvFilesEditorShow(Sender: TObject);
begin
  gTorrents.Tag:=1;
  lvFiles.Tag:=1;
  lvFiles.RemoveSelection;
  lvFiles.HideSelection:=False;
end;

procedure TMainForm.lvFilesSetEditText(Sender: TObject; ACol, ARow: Integer; const Value: string);
var
  p: string;
  i, lvl, len: integer;
begin
  p:=FFilesTree.GetFullPath(ARow, False);
  if RenameTorrent(gTorrents.Items[idxTorrentId, gTorrents.Row], p, Trim(Value)) then begin
    FFiles[idxFileName, ARow]:=UTF8Decode(Trim(Value));
    if FFilesTree.IsFolder(ARow) then begin
      // Updating path for child elements
      len:=Length(p);
      p:=ExtractFilePath(p) + Trim(Value);
      lvl:=FFilesTree.RowLevel[ARow];
      FFiles.BeginUpdate;
      try
        FFiles[idxFileFullPath, ARow]:=UTF8Decode(p + RemotePathDelimiter);
        for i:=ARow + 1 to FFiles.Count - 1 do
          if FFilesTree.RowLevel[i] > lvl then
            FFiles[idxFileFullPath, i]:=UTF8Decode(p + Copy(UTF8Encode(widestring(FFiles[idxFileFullPath, i])), len + 1, MaxInt))
          else
            break;
      finally
        FFiles.EndUpdate;
      end;
    end;
  end;
end;

procedure TMainForm.lvFilterCellAttributes(Sender: TVarGrid; ACol, ARow, ADataCol: integer; AState: TGridDrawState; var CellAttribs: TCellAttributes);
var t: Integer;
begin
  if ARow < 0 then exit;
  with CellAttribs do begin
    case ARow of
      0: ImageIndex:=imgAll;
      1: ImageIndex:=imgDown;
      2: ImageIndex:=imgSeed;
      3: ImageIndex:=imgActive;
      4: ImageIndex:=imgInactive;
      5: ImageIndex:=imgStopped;
      6: ImageIndex:=imgError;
      7: ImageIndex:=imgWaiting
      else
        if Text <> '' then
          if VarIsNull(Sender.Items[-1, ARow]) then
            ImageIndex:=5
          else begin
            t:=Integer(Sender.Items[-2, ARow]);
            if t = 1 then
              ImageIndex:=22
            else
              ImageIndex:=44;
          end;
    end;
  end;
end;

procedure TMainForm.lvFilterClick(Sender: TObject);
begin
  if VarIsNull(lvFilter.Items[0, lvFilter.Row]) then
    if (FLastFilerIndex > lvFilter.Row) or (lvFilter.Row = lvFilter.Items.Count - 1) then
      lvFilter.Row:=lvFilter.Row - 1
    else
      lvFilter.Row:=lvFilter.Row + 1;
  FLastFilerIndex:=lvFilter.Row;
  FilterTimer.Enabled:=False;
  FilterTimer.Enabled:=True;
end;

procedure TMainForm.lvFilterDrawCell(Sender: TVarGrid; ACol, ARow, ADataCol: integer; AState: TGridDrawState; const R: TRect;
  var ADefaultDrawing: boolean);
var
  i: integer;
  RR: TRect;
begin
  ADefaultDrawing:=not VarIsNull(Sender.Items[0, ARow]);
  if ADefaultDrawing then exit;

  with lvFilter.Canvas do begin
    Brush.Color:=lvFilter.Color;
    FillRect(R);
    i:=(R.Bottom + R.Top) div 2;
    Brush.Color:=clBtnFace;
    RR:=R;
    InflateRect(RR, -4, 0);
    RR.Top:=i - 1;
    RR.Bottom:=i + 1;
    FillRect(RR);
  end;
end;

procedure TMainForm.lvPeersCellAttributes(Sender: TVarGrid; ACol, ARow, ADataCol: integer; AState: TGridDrawState; var CellAttribs: TCellAttributes);
var
  i: integer;
begin
  if ARow < 0 then exit;
  with CellAttribs do begin
    if Text = '' then exit;
    if ACol = 0 then begin
      ImageIndex:=Sender.Items[idxPeerCountryImage, ARow];
      if ImageIndex = 0 then
        ImageIndex:=-1;
    end;
    case ADataCol of
      idxPeerDone:
        Text:=Format('%.1f%%', [double(Sender.Items[ADataCol, ARow])*100.0]);
      idxPeerDownSpeed, idxPeerUpSpeed:
        begin
          i:=Sender.Items[ADataCol, ARow];
          if i > 0 then
            Text:=GetHumanSize(i, 1) + sPerSecond
          else
            Text:='';
        end;
    end;
  end;
end;

procedure TMainForm.lvTrackersCellAttributes(Sender: TVarGrid; ACol, ARow, ADataCol: integer; AState: TGridDrawState; var CellAttribs: TCellAttributes);
var
  f: double;
begin
  if ARow < 0 then exit;
  with CellAttribs do begin
    if Text = '' then exit;
    case ADataCol of
      idxTrackersListSeeds:
        if lvTrackers.Items[ADataCol, ARow] < 0 then
          Text:='';
      idxTrackersListUpdateIn:
        begin
          f:=double(lvTrackers.Items[ADataCol, ARow]);
          if f = 0 then
            Text:='-'
          else
          if f = 1 then
            Text:=sUpdating
          else
            Text:=SecondsToString(Trunc(f));
        end;
    end;
  end;
end;

procedure TMainForm.lvTrackersDblClick(Sender: TObject);
begin
  acEditTracker.Execute;
end;

procedure TMainForm.lvTrackersKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_DELETE then begin
    Key:=0;
    acDelTracker.Execute;
  end;
end;

procedure TMainForm.goDevelopmentSiteClick(Sender: TObject);
begin
  goGitHub;
end;

procedure TMainForm.MainToolBarContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
begin
    acBigToolBar.Execute;
end;

procedure TMainForm.MenuItem101Click(Sender: TObject);
var
  req, args, tt: TJSONObject;
  ids, t: TJSONArray;
  i: Integer;
  TorrentIds: Variant;
  Magnets: TStringList;
begin
  TorrentIds:=GetSelectedTorrents;
  req:=TJSONObject.Create;
  args:=TJSONObject.Create;
  Magnets:=TStringList.Create;
  try
    req.Add('method', 'torrent-get');
    ids:=TJSONArray.Create;
    for i:=VarArrayLowBound(TorrentIds, 1) to VarArrayHighBound(TorrentIds, 1) do
      ids.Add(integer(TorrentIds[i]));
    args.Add('ids', ids);
    args.Add('fields', TJSONArray.Create(['magnetLink']));
    req.Add('arguments', args);
    args:=RpcObj.SendRequest(req);
    if args = nil then begin
      CheckStatus(False);
      exit;
    end;
    t:=TJSONArray.Create;
    t:=args.Arrays['torrents'];
    for i:= 0 to t.Count-1 do
      begin
        tt:=t.Objects[i] as TJSONObject;
        Magnets.add(tt.Strings['magnetLink']);
      end;
    FLastClipboardLink := Magnets.Text;   // To Avoid TransGUI detect again this existing links
    Clipboard.AsText := Magnets.Text;
  finally
    req.Free;
    args.Free;
    Magnets.Free;
  end;
end;

procedure TMainForm.miHomePageClick(Sender: TObject);
begin
  GoHomePage;
end;

procedure TMainForm.PageInfoResize(Sender: TObject);
begin
  if FDetailsWait.Visible then
    CenterDetailsWait;
end;

procedure TMainForm.panReconnectResize(Sender: TObject);
begin
  panReconnectFrame.BoundsRect:=panReconnect.ClientRect;
end;

procedure TMainForm.pbDownloadedPaint(Sender: TObject);
begin
  if FTorrentProgress <> nil then
    pbDownloaded.Canvas.StretchDraw(pbDownloaded.ClientRect, FTorrentProgress);
end;

procedure TMainForm.StatusBarMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  pt: TPoint;
  rb: boolean;
begin
  rb:=(Button = mbRight) and RpcObj.Connected;
  pt:=StatusBar.ClientToScreen(Point(X, Y));
  case StatusBar.GetPanelIndexAt(X, Y) of
    0: if Button = mbLeft then
        acConnOptions.Execute;
    1: if rb then
        pmDownSpeeds.PopUp(pt.X, pt.Y);
    2: if rb then
        pmUpSpeeds.PopUp(pt.X, pt.Y);
  end;
end;

{$ifdef LCLcarbon}
type
  THackApplication = class(TApplication)
  end;
{$endif LCLcarbon}

procedure TMainForm.TickTimerTimer(Sender: TObject);
var
  i: integer;
begin
  TickTimer.Enabled:=False;
  try
    if not FStarted then begin
      Application.ProcessMessages;
      FStarted:=True;
      acConnect.Execute;
      Application.ProcessMessages;
      panTransfer.ChildSizing.Layout:=cclLeftToRightThenTopToBottom;
      panGeneralInfo.ChildSizing.Layout:=cclLeftToRightThenTopToBottom;
      panTransfer.ChildSizing.Layout:=cclNone;
      panGeneralInfo.ChildSizing.Layout:=cclNone;
      with panTransfer do
        ClientHeight:=Controls[ControlCount - 1].BoundsRect.Bottom + ChildSizing.TopBottomSpacing;
      with panGeneralInfo do
        ClientHeight:=Controls[ControlCount - 1].BoundsRect.Bottom + ChildSizing.TopBottomSpacing;
      panSearch.AutoSize:=False;

      if Ini.ReadBool('MainForm', 'FirstRun', True) then begin
        if not acResolveCountry.Checked then
          acResolveCountry.Execute;
        if acResolveCountry.Checked and not acShowCountryFlag.Checked then
          acShowCountryFlag.Execute;
        Ini.WriteBool('MainForm', 'FirstRun', False);
      end;

      i:=Ini.ReadInteger('Interface', 'LastNewVersionCheck', Trunc(Now));
      if i + Ini.ReadInteger('Interface', 'CheckNewVersionDays', 5) <= Trunc(Now) then begin
        if Ini.ReadBool('Interface', 'AskCheckNewVersion', True) then begin
          Ini.WriteBool('Interface', 'AskCheckNewVersion', False);
          if not Ini.ReadBool('Interface', 'CheckNewVersion', False) then
            if MessageDlg(Format(SCheckNewVersion, [AppName]), mtConfirmation, mbYesNo, 0) = mrYes then
              Ini.WriteBool('Interface', 'CheckNewVersion', True);
        end;
        if Ini.ReadBool('Interface', 'CheckNewVersion', False) then
          CheckNewVersion;
      end;
    end;

    CheckAddTorrents;

    if RpcObj.Connected then
      FReconnectTimeOut:=0
    else
      if panReconnect.Visible then
        if Now - FReconnectWaitStart >= FReconnectTimeOut/SecsPerDay then
          DoConnect
        else
          begin
          txReconnectSecs.Caption:=Format(sReconnect, [FReconnectTimeOut - Round(SecsPerDay*(Now - FReconnectWaitStart))]);
          panReconnect.Constraints.MinWidth:=450;
          end;

    if FSlowResponse.Visible then begin
      if RpcObj.RequestStartTime = 0 then
        FSlowResponse.Visible:=False;
    end
    else
      if (RpcObj.RequestStartTime <> 0) and (Now - RpcObj.RequestStartTime >= 1/SecsPerDay) then
        FSlowResponse.Visible:=True;

    if FDetailsWait.Visible then begin
      if (FDetailsWaitStart = 0) or not (rtDetails in RpcObj.RefreshNow) then begin
        FDetailsWaitStart:=0;
        FDetailsWait.Visible:=False;
        panDetailsWait.Visible:=False;
      end;
    end
    else
      if (FDetailsWaitStart <> 0) and (Now - FDetailsWaitStart >= 300/MSecsPerDay) then begin
        CenterDetailsWait;
        FDetailsWait.Visible:=True;
        panDetailsWait.Visible:=True;
        panDetailsWait.BringToFront;
      end;

{$ifdef LCLcarbon}
    THackApplication(Application).ProcessAsyncCallQueue;
    if Active and (WindowState <> wsMinimized) then begin
      if not FFormActive then begin
        FFormActive:=True;
        CheckClipboardLink;
      end;
    end
    else
      FFormActive:=False;
{$endif LCLcarbon}
  finally
    TickTimer.Enabled:=True;
  end;
end;

procedure TMainForm.FilterTimerTimer(Sender: TObject);
begin
  FilterTimer.Enabled:=False;
  FFilterChanged:=True;
  DoRefresh(True);
end;

procedure TMainForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
{$ifdef CPUARM}
//  CloseAction:=caMinimize;
  BeforeCloseApp;
  exit;
{$endif CPUARM}

  if Ini.ReadBool('Interface', 'TrayClose', False) then begin
{$ifdef darwin}
    CloseAction:=caMinimize;
{$else}
{$ifdef linux}
    if IsUnity then
      CloseAction:=caMinimize
    else
{$endif linux}
    begin
      CloseAction:=caHide;
      HideApp;
      UpdateTray;
    end;
{$endif darwin}
    exit;
  end;
  BeforeCloseApp;
end;

procedure TMainForm.PageInfoChange(Sender: TObject);
begin
  if PageInfo.ActivePage.Tag <> 0 then
    FDetailsWaitStart:=Now;
  RpcObj.Lock;
  try
    RpcObj.AdvInfo:=GetPageInfoType(PageInfo.ActivePage);
    DoRefresh;
  finally
    RpcObj.Unlock;
  end;
end;

procedure TMainForm.tbSearchCancelClick(Sender: TObject);
begin
      edSearch.Text:='';
end;

procedure TMainForm.TorrentsListTimerTimer(Sender: TObject);
begin
  TorrentsListTimer.Enabled:=False;
  if RpcObj.CurTorrentId <> 0 then
    FDetailsWaitStart:=Now;
  DoRefresh;
end;

procedure TMainForm.pmFilesPopup(Sender: TObject);
begin
  UpdateUI;
end;

procedure TMainForm.pmTorrentsPopup(Sender: TObject);
begin
  UpdateUI;
end;

procedure TMainForm.TrayIconDblClick(Sender: TObject);
begin
{$ifndef darwin}
//  acShowApp.Execute;
if (MainForm.Visible = false) or (MainForm.WindowState = wsMinimized) then
    MainForm.ShowApp
    else
    MainForm.HideApp;
{$endif darwin}
end;

procedure TMainForm.VSplitterChangeBounds(Sender: TObject);
begin
{$ifdef windows}
  Update;
{$endif windows}
end;

procedure TMainForm.UrlLabelClick(Sender: TObject);
begin
  AppBusy;
  OpenURL((Sender as TLabel).Caption);
  AppNormal;
end;

procedure TMainForm.CenterReconnectWindow;
begin
  CenterOnParent(panReconnect);
end;

function TMainForm.DoConnect: boolean;
var
  Sec, pwd: string;
  i, j: integer;
begin
  Result:=True;
  panReconnect.Hide;
  DoDisconnect;
  Sec:='Connection.' + FCurConn;
  if not Ini.SectionExists(Sec) then
    Sec:='Connection';

  i:=FPasswords.IndexOfName(FCurConn);
  pwd:=Ini.ReadString(Sec, 'Password', '');
  if pwd = '-' then begin
    if i >= 0 then
      pwd:=FPasswords.ValueFromIndex[i]
    else begin
      pwd := '';
      // own dialog for entering a password (****)
      with TPasswordConnect.Create(Self) do
      try
        SetText(Format(SConnectTo, [FCurConn]), Format(SEnterPassword, [FCurConn]));
        if ShowModal <> mrOk then begin
          RpcObj.Url:='-';
          Result:=False;
          exit;
        end else begin
          pwd := gPassw
        end;
      finally
        Free;
      end;
    end;
  end
  else
    pwd:=DecodeBase64(pwd);
  if i >= 0 then
    FPasswords.Delete(i);

  RpcObj.Http.Sock.SSL.PFXfile:='';
  RpcObj.Http.Sock.SSL.KeyPassword:='';
  if Ini.ReadBool(Sec, 'UseSSL', False) then begin
    RpcObj.InitSSL;
    RpcObj.Http.Sock.SSL.PFXfile:=Ini.ReadString(Sec, 'CertFile', '');
    RpcObj.Http.Sock.SSL.KeyPassword:=DecodeBase64(Ini.ReadString(Sec, 'CertPass', ''));
    if not IsSSLloaded then begin
      MessageDlg(Format(sSSLLoadError, [DLLSSLName, DLLUtilName]), mtError, [mbOK], 0);
      exit;
    end;
    RpcObj.Url:='https';
  end
  else
    RpcObj.Url:='http';
  RpcObj.Http.UserName:=Ini.ReadString(Sec, 'UserName', '');
  RpcObj.Http.Password:=pwd;
  RpcObj.Http.ProxyHost:='';
  RpcObj.Http.ProxyPort:='';
  RpcObj.Http.ProxyUser:='';
  RpcObj.Http.ProxyPass:='';
  RpcObj.Http.Sock.SocksIP:='';
  RpcObj.Http.Sock.SocksPort:='';
  RpcObj.Http.Sock.SocksUsername:='';
  RpcObj.Http.Sock.SocksPassword:='';
  if Ini.ReadBool(Sec, 'UseProxy', False) then begin
    if Ini.ReadBool(Sec, 'UseSockProxy', False) then begin
      RpcObj.Http.Sock.SocksIP := Ini.ReadString(Sec, 'ProxyHost', '');
      RpcObj.Http.Sock.SocksPort := IntToStr(Ini.ReadInteger(Sec, 'ProxyPort', 8080));
      RpcObj.Http.Sock.SocksUsername := Ini.ReadString(Sec, 'ProxyUser', '');
      RpcObj.Http.Sock.SocksPassword := DecodeBase64(Ini.ReadString(Sec, 'ProxyPass', ''));
    end
    else begin
      RpcObj.Http.ProxyHost:=Ini.ReadString(Sec, 'ProxyHost', '');
      RpcObj.Http.ProxyPort:=IntToStr(Ini.ReadInteger(Sec, 'ProxyPort', 8080));
      RpcObj.Http.ProxyUser:=Ini.ReadString(Sec, 'ProxyUser', '');
      RpcObj.Http.ProxyPass:=DecodeBase64(Ini.ReadString(Sec, 'ProxyPass', ''));
    end;
  end;
  if (FReconnectTimeOut = -1) and Ini.ReadBool(Sec, 'Autoreconnect', False) then
        FReconnectTimeOut:=0;
  RpcObj.RpcPath:=Ini.ReadString(Sec, 'RpcPath', '');
  RpcObj.Url:=Format('%s://%s:%d', [RpcObj.Url, Ini.ReadString(Sec, 'Host', ''), Ini.ReadInteger(Sec, 'Port', 9091)]);
  SetRefreshInterval;
  RpcObj.InfoStatus:=sConnectingToDaemon;
  CheckStatus;
  TrayIcon.Hint:=RpcObj.InfoStatus;
  RpcObj.Connect;
  FPathMap.Text:=StringReplace(Ini.ReadString(Sec, 'PathMap', ''), '|', LineEnding, [rfReplaceAll]);
  i:=0;
  while i < FPathMap.Count do
    if Trim(FPathMap.ValueFromIndex[i]) = '' then
      FPathMap.Delete(i)
    else
      Inc(i);

  Ini.WriteString('Hosts', 'CurHost', FCurConn);
  if FCurConn <> Ini.ReadString('Hosts', 'Host1', '') then begin
    Ini.WriteString('Hosts', 'Host1', FCurConn);
    j:=2;
    for i:=0 to pmConnections.Items.Count - 1 do
      with pmConnections.Items[i] do
        if (Tag = 0) and (Caption <> FCurConn) then begin
          Ini.WriteString('Hosts', Format('Host%d', [j]), Caption);
          Inc(j);
        end;
    Ini.UpdateFile;
    UpdateConnections;
  end
  else
    if pmConnections.Items[0].Tag = 0 then begin
      pmConnections.Items[0].Checked:=True;
      miConnect.Items[0].Checked:=True;
    end;
  tbConnect.Caption := pmConnections.Items[0].Caption;
end;

procedure TMainForm.DoDisconnect;
var
  i: integer;
begin
  TorrentsListTimer.Enabled:=False;
  FilterTimer.Enabled:=False;
  ClearDetailsInfo;
  gTorrents.Items.Clear;
  gTorrents.Enabled:=False;
  gTorrents.Color:=clBtnFace;
  lvPeers.Enabled:=False;
  lvPeers.Color:=gTorrents.Color;
  lvFiles.Enabled:=False;
  lvFiles.Color:=gTorrents.Color;
  lvTrackers.Enabled:=False;
  lvTrackers.Color:=gTorrents.Color;

  lvFilter.Enabled:=False;
  lvFilter.Color:=gTorrents.Color;
  with lvFilter do begin
    Items[0, 0]:=UTF8Decode(SAll); // ALERT - VERIFY - PETROV
    Items[0, 1]:=UTF8Decode(SDownloading);
    Items[0, 2]:=UTF8Decode(SCompleted);
    Items[0, 3]:=UTF8Decode(SActive);
    Items[0, 4]:=UTF8Decode(SInactive);
    Items[0, 5]:=UTF8Decode(sStopped);
    Items[0, 6]:=UTF8Decode(sErrorState);
    Items[0, 7]:=UTF8Decode(sWaiting);
  end;
  edSearch.Enabled:=False;
  edSearch.Color:=gTorrents.Color;
  edSearch.Text:='';

  with gStats do begin
    BeginUpdate;
    try
      for i:=0 to Items.Count - 1 do begin
        Items[1, i]:=NULL;
        Items[2, i]:=NULL;
      end;
    finally
      EndUpdate;
    end;
    Enabled:=False;
    Color:=gTorrents.Color;
  end;

  RpcObj.Disconnect;

  RpcObj.InfoStatus:=sDisconnected;
  CheckStatus;
  UpdateUI;
  TrayIcon.Hint:=RpcObj.InfoStatus;
  gTorrents.Items.RowCnt:=0;
  FTorrents.RowCnt:=0;
  lvFilter.Row:=0;
  lvFilter.Items.RowCnt:=StatusFiltersCount;
  TorrentsListTimer.Enabled:=False;
  FilterTimer.Enabled:=False;
  pmConnections.Items[0].Checked:=False;
  miConnect.Items[0].Checked:=False;
  FCurDownSpeedLimit:=-2;
  FCurUpSpeedLimit:=-2;
  FillSpeedsMenu;
  tbConnect.Caption := Format(SConnectTo,['Transmission']);
end;

procedure TMainForm.ClearDetailsInfo(Skip: TAdvInfoType);

  procedure ClearChildren(AParent: TPanel);
  var
    i: integer;
  begin
    AParent.AutoSize:=False;
    AParent.ChildSizing.Layout:=cclNone;
    for i:=0 to AParent.ControlCount - 1 do begin
      if AParent.Controls[i] is TLabel then
        with AParent.Controls[i] as TLabel do begin
          if (Length(Name) < 5) or (Copy(Name, Length(Name) - 4, 5) <> 'Label') then
            Caption:='';
          PopupMenu:=pmLabels;
        end;
    end;
  end;

var
  i, t: integer;
begin
  if RpcObj.CurTorrentId = 0 then begin
    Skip:=aiNone;
    t:=0;
  end
  else
    t:=1;
  FDetailsWaitStart:=0;
  if Skip <> aiFiles then begin
    FFiles.Clear;
    tabFiles.Caption:=FFilesCapt;
  end;
  if Skip <> aiPeers then
    lvPeers.Items.Clear;
  if Skip <> aiTrackers then
    lvTrackers.Items.Clear;
  if Skip <> aiGeneral then begin
    ClearChildren(panGeneralInfo);
    ClearChildren(panTransfer);
    ProcessPieces('', 0, 0);
    txDownProgress.AutoSize:=False;
    txDownProgress.Caption:='';

    txMagnetLink.Text := '';
  end;
  for i:=0 to PageInfo.PageCount - 1 do
    PageInfo.Pages[i].Tag:=t;
end;

function TMainForm.SelectRemoteFolder(const CurFolder, DialogTitle: string): string;
var
  i, j: integer;
  s, ss, sss, fn: string;
  dlg: TSelectDirectoryDialog;
  d: char;
begin
  Result:='';
  if Trim(FPathMap.Text) = '' then begin
    MessageDlg(sNoPathMapping, mtInformation, [mbOK], 0);
    exit;
  end;
  s:=MapRemoteToLocal(CurFolder);
  if (s = '') or not DirectoryExistsUTF8(s) then
    s:=FPathMap.ValueFromIndex[0];

  if not DirectoryExistsUTF8(s) then begin
    MessageDlg(sNoPathMapping, mtInformation, [mbOK], 0);
    exit;
  end;

  dlg:=TSelectDirectoryDialog.Create(nil);
  try
    dlg.Title:=DialogTitle;
    dlg.InitialDir:=s;
    if not dlg.Execute then
      exit;

    fn:=dlg.FileName;
    for i:=0 to FPathMap.Count - 1 do begin
      s:=FPathMap[i];
      j:=Pos('=', s);
      if j > 0 then begin
        ss:=FixSeparators(Copy(s, j + 1, MaxInt));
        sss:=IncludeTrailingPathDelimiter(ss);
        if (CompareFilePath(ss, fn) = 0) or (CompareFilePath(sss, Copy(fn, 1, Length(sss))) = 0) then begin
          Result:=Copy(s, 1, j - 1);
          d:='/';
          for j:=1 to Length(Result) do
            if Result[j] in ['/','\'] then begin
              d:=Result[j];
              break;
            end;
          if CompareFilePath(ss, fn) <> 0 then begin
            if (Result <> '') and (Copy(Result, Length(Result), 1) <> d) then
              Result:=Result + d;
            ss:=IncludeProperTrailingPathDelimiter(ss);
            Result:=Result + Copy(fn, Length(ss) + 1, MaxInt);
          end;

          Result:=StringReplace(Result, DirectorySeparator, d, [rfReplaceAll]);
          if Copy(Result, Length(Result), 1) = d then
            SetLength(Result, Length(Result) - 1);
        end;
      end;
    end;
  finally
    dlg.Free;
  end;
  if Result = '' then
    MessageDlg(sNoPathMapping, mtError, [mbOK], 0);
end;

procedure TMainForm.ConnectionSettingsChanged(const ActiveConnection: string; ForceReconnect: boolean);
var
  Sec: string;
begin
  UpdateConnections;
  if (FCurConn <> ActiveConnection) or ForceReconnect then begin
    DoDisconnect;
    Sec:='Connection.' + ActiveConnection;
    if Ini.ReadBool(Sec, 'Autoreconnect', False) then
      FReconnectTimeOut:=0
    else
    FReconnectTimeOut:=-1;
    FCurConn:=ActiveConnection;
    if FCurConn <> '' then
      DoConnect;
  end;
end;

procedure TMainForm.UpdateUI;
var
  e: boolean;
begin
  e:=((Screen.ActiveForm = Self) or not Visible or (WindowState = wsMinimized))
    and not gTorrents.EditorMode and not lvFiles.EditorMode;

  acConnect.Enabled:=e;
  acOptions.Enabled:=e;
  acConnOptions.Enabled:=e;
  e:=RpcObj.Connected and e;
  acDisconnect.Enabled:=e;
  acSelectAll.Enabled:=e;
  acAddTorrent.Enabled:=e;
  acAddLink.Enabled:=e;
  acDaemonOptions.Enabled:=e;
  acStartAllTorrents.Enabled:=e and RpcObj.Connected;
  acStopAllTorrents.Enabled:=acStartAllTorrents.Enabled;
  acStartTorrent.Enabled:=e and (gTorrents.Items.Count > 0);
  acForceStartTorrent.Enabled:=acStartTorrent.Enabled and (RpcObj.RPCVersion >= 14);
  acStopTorrent.Enabled:=e and (gTorrents.Items.Count > 0);
  acVerifyTorrent.Enabled:=e and (gTorrents.Items.Count > 0);
  acRemoveTorrent.Enabled:=e and (gTorrents.Items.Count > 0) and not edSearch.Focused;
  acRemoveTorrentAndData.Enabled:=acRemoveTorrent.Enabled and (RpcObj.RPCVersion >= 4);
  acReannounceTorrent.Enabled:=acVerifyTorrent.Enabled and (RpcObj.RPCVersion >= 5);
  acMoveTorrent.Enabled:=acVerifyTorrent.Enabled and (RpcObj.RPCVersion >= 6);
  acSetLabels.Enabled:=acVerifyTorrent.Enabled and (RpcObj.RPCVersion >= 16);
  acTorrentProps.Enabled:=acVerifyTorrent.Enabled;
  acOpenContainingFolder.Enabled:=acTorrentProps.Enabled and (RpcObj.RPCVersion >= 4);
  pmiPriority.Enabled:=e and (gTorrents.Items.Count > 0);
  miPriority.Enabled:=pmiPriority.Enabled;
  acSetHighPriority.Enabled:=e and (gTorrents.Items.Count > 0) and
                      ( ( not lvFiles.Focused and (RpcObj.RPCVersion >= 5) ) or
                        ((lvFiles.Items.Count > 0) and (PageInfo.ActivePage = tabFiles)) );
  acSetNormalPriority.Enabled:=acSetHighPriority.Enabled;
  acSetLowPriority.Enabled:=acSetHighPriority.Enabled;
  miQueue.Enabled:=e and (gTorrents.Items.Count > 0) and (RpcObj.RPCVersion >= 14);
  pmiQueue.Enabled:=miQueue.Enabled;
  acQMoveTop.Enabled:=miQueue.Enabled;
  acQMoveUp.Enabled:=miQueue.Enabled;
  acQMoveDown.Enabled:=miQueue.Enabled;
  acQMoveBottom.Enabled:=miQueue.Enabled;
  acOpenFile.Enabled:=acSetHighPriority.Enabled and (lvFiles.SelCount < 2) and (RpcObj.RPCVersion >= 4);
  acCopyPath.Enabled:=acOpenFile.Enabled;
  acSetNotDownload.Enabled:=acSetHighPriority.Enabled;
  acRename.Enabled:=(RpcObj.RPCVersion >= 15) and acSetHighPriority.Enabled;
  acSetupColumns.Enabled:=e;
  acUpdateBlocklist.Enabled:=(acUpdateBlocklist.Tag <> 0) and e and (RpcObj.RPCVersion >= 5);
  acAddTracker.Enabled:=acTorrentProps.Enabled and (RpcObj.RPCVersion >= 10);
  acAdvEditTrackers.Enabled:=acAddTracker.Enabled;
  acEditTracker.Enabled:=acAddTracker.Enabled and (lvTrackers.Items.Count > 0);
  acDelTracker.Enabled:=acEditTracker.Enabled;
  acAltSpeed.Enabled:=e and (RpcObj.RPCVersion >= 5);
  pmiDownSpeedLimit.Enabled:=RpcObj.Connected;
  pmiUpSpeedLimit.Enabled:=RpcObj.Connected;
end;

procedure TMainForm.ShowConnOptions(NewConnection: boolean);
var
  frm: TConnOptionsForm;
begin
  AppBusy;
  frm:=TConnOptionsForm.Create(Self);
  with frm do
  try
    ActiveConnection:=FCurConn;
    if NewConnection then begin
      Caption:=SNewConnection;
      btNewClick(nil);
      if Ini.ReadInteger('Hosts', 'Count', 0) = 0 then begin
        panTop.Visible:=False;
{$ifdef LCLgtk2}
        panTop.Height:=0;
{$endif LCLgtk2}
        with Page.BorderSpacing do
          Top:=Left;
        tabPaths.TabVisible:=False;
        tabMisc.TabVisible:=False;
      end
      else begin
        btNew.Hide;
        btRename.Hide;
        btDel.Hide;
        panTop.ClientHeight:=btNew.Top;
      end;
      cbShowAdvancedClick(nil);
      AutoSizeForm(frm);
    end;
    AppNormal;
    ShowModal;
    ConnectionSettingsChanged(ActiveConnection, ActiveSettingChanged);
  finally
    Free;
  end;
end;

procedure TMainForm.SaveColumns(LV: TVarGrid; const AName: string; FullInfo: boolean);
var
  i: integer;
begin
  for i:=0 to LV.Columns.Count - 1 do
    with LV.Columns[i] do begin
      Ini.WriteInteger(AName, Format('Id%d', [i]), ID - 1);
      Ini.WriteInteger(AName, Format('Width%d', [i]), Width);
      if FullInfo then begin
        Ini.WriteInteger(AName, Format('Index%d', [i]), Index);
        Ini.WriteBool(AName, Format('Visible%d', [i]), Visible);
      end;
    end;
  if LV.SortColumn >= 0 then begin
    Ini.WriteInteger(AName, 'SortColumn', LV.SortColumn);
    Ini.WriteInteger(AName, 'SortOrder', integer(LV.SortOrder));
  end;
end;

procedure TMainForm.LoadColumns(LV: TVarGrid; const AName: string; FullInfo: boolean);
var
  i, j, ColId: integer;
begin
  LV.Columns.BeginUpdate;
  try
    for i:=0 to LV.Columns.Count - 1 do begin
      ColId:=Ini.ReadInteger(AName, Format('Id%d', [i]), -1);
      if ColId = -1 then continue;
      for j:=0 to LV.Columns.Count - 1 do
        with LV.Columns[j] do
          if ID - 1 = ColId then begin
            if FullInfo then begin
              Index:=Ini.ReadInteger(AName, Format('Index%d', [i]), Index);
              Visible:=Ini.ReadBool(AName, Format('Visible%d', [i]), Visible);
            end;
            Width:=Ini.ReadInteger(AName, Format('Width%d', [i]), Width);
            break;
          end;
    end;
  finally
    LV.Columns.EndUpdate;
  end;
  LV.SortColumn:=Ini.ReadInteger(AName, 'SortColumn', LV.SortColumn);
  LV.SortOrder:=TSortOrder(Ini.ReadInteger(AName, 'SortOrder', integer(LV.SortOrder)));
end;


//----------------------------------------------------------------
function GetBiDi: TBiDiMode;
var
  i:integer;
begin
  // PETROV - Herb off
  i:=Ini.ReadInteger ('Interface', 'IgnoreRightLeft', 0);   // 0 - by default
    Ini.WriteInteger('Interface', 'IgnoreRightLeft', i);

  if (FTranslationLanguage='English') and (i=0) then
    i := 1;

  Result := bdLeftToRight;
  case i of
    1: Result := bdLeftToRight;
    2: Result := bdRightToLeft;
    3: Result := bdRightToLeftNoAlign;
    4: Result := bdRightToLeftReadingOnly;
  end;
end;


//----------------------------------------------------------------
function ExcludeInvalidChar (path: string): string;
var
  s_old: string;
  l_old: integer;
begin
  s_old := path;
//path  := StringReplace(path, ':', '_', [rfReplaceAll, rfIgnoreCase]);
  path  := StringReplace(path, '*', '_', [rfReplaceAll, rfIgnoreCase]);
  path  := StringReplace(path, '?', '_', [rfReplaceAll, rfIgnoreCase]);
  path  := StringReplace(path, '|', '_', [rfReplaceAll, rfIgnoreCase]);
  path  := StringReplace(path, '<', '_', [rfReplaceAll, rfIgnoreCase]);
  path  := StringReplace(path, '>', '_', [rfReplaceAll, rfIgnoreCase]);
  path  := StringReplace(path, '"', '_', [rfReplaceAll, rfIgnoreCase]);
  path  := StringReplace(path, '~', '_', [rfReplaceAll, rfIgnoreCase]);
//path  := StringReplace(path, '..','_', [rfReplaceAll, rfIgnoreCase]); bag

  l_old := 0;
  if path <> s_old then begin
    l_old :=1;
  end;

  Result:= path;
end;



//----------------------------------------------------------------
function TMainForm.CorrectPath (path: string): string; // PETROV
var
  l_old: integer;
begin
  path  := StringReplace(path, '//', '/', [rfReplaceAll, rfIgnoreCase]);
  Result:= path;
  l_old := length(path);
  if l_old >= 1 then begin
    if path[l_old]='/' then
        path := MidStr(path,1,l_old-1);
    Result:= path;
  end;
end;





function TMainForm.GetTorrentError(t: TJSONObject; Status: integer): string;
var
  i: integer;
  stats: TJSONArray;
  err, gerr: widestring;
  NoTrackerError: boolean;
begin
  Result:='';
  gerr:=t.Strings['errorString'];
  if RpcObj.RPCVersion >= 7 then begin
    NoTrackerError:=False;
    stats:=t.Arrays['trackerStats'];
    for i:=0 to stats.Count - 1 do
      with stats.Objects[i] do begin
        err:='';
        if Booleans['hasAnnounced'] and not Booleans['lastAnnounceSucceeded'] then
          err:=Strings['lastAnnounceResult'];
        if err = 'Success' then
          err:='';
        if err = '' then begin
          // If at least one tracker is working, then report no error
          NoTrackerError:=True;
          Result:='';
        end
        else begin
          if not NoTrackerError and (Result = '') then
            Result:=sTrackerError + ': ' + UTF8Encode(err);
          // Workaround for transmission bug
          // If the global error string is equal to some tracker error string,
          // then igonore the global error string
          if gerr = err then
            gerr:='';
        end;
      end;
  end
  else begin
    Result:=UTF8Encode(t.Strings['announceResponse']);
    if Result = 'Success' then
      Result:=''
    else
      if Result <> '' then begin
        i:=Pos('(', Result);
        if i <> 0 then
          if Copy(Result, i, 5) = '(200)' then
            Result:=''
          else
            Result:=sTrackerError + ': ' + Copy(Result, 1, i - 1);
      end;
  end;

  if (Result = '') or (Status = TR_STATUS_STOPPED) or (Status = TR_STATUS_FINISHED) then
    Result:=UTF8Encode(gerr);
end;

function TMainForm.SecondsToString(j: integer): string;
begin
  if j < 60 then
    Result:=Format(sSecs, [j])
  else
  if j < 60*60 then begin
    Result:=Format(sMins, [j div 60]);
    j:=j mod 60;
    if j > 0 then
      Result:=Format('%s, %s', [Result, Format(sSecs, [j])]);
  end
  else begin
    j:=(j + 30) div 60;
    if j < 60*24 then begin
      Result:=Format(sHours, [j div 60]);
      j:=j mod 60;
      if j > 0 then
        Result:=Format('%s, %s', [Result, Format(sMins, [j])]);
    end
    else begin
      j:=(j + 30) div 60;
      Result:=Format(sDays, [j div 24]);
      j:=j mod 24;
      if j > 0 then
        Result:=Format('%s, %s', [Result, Format(sHours, [j])]);
    end;
  end;
end;

procedure TMainForm.FillTorrentsList(list: TJSONArray);
var
  i, j, p, row, crow, id, StateImg: integer;
  t: TJSONObject;
  a: TJSONArray;
  f: double;
  ExistingRow: boolean;
  s, ss: string;

  function GetTorrentValue(AIndex: integer; const AName: string; AType: integer): boolean;
  var
    res: variant;
    i: integer;
  begin
    i:=t.IndexOfName(AName);
    Result:=i >= 0;
    if Result then
      case AType of
        vtInteger:
          res:=t.Items[i].AsInteger;
        vtExtended:
          res:=t.Items[i].AsFloat;
        else
          res:=t.Items[i].AsString;
      end
    else
      res:=NULL;

    FTorrents[AIndex, row]:=res;
  end;

  function StoreSpeed(var History: variant; Speed: integer): integer;
  var
    j, cnt: integer;
    p: PInteger;
    IsNew: boolean;
    res: Int64;
  begin
    IsNew:=VarIsEmpty(History);
    if IsNew then begin
      if Speed = 0 then begin
        Result:=0;
        exit;
      end;
      History:=VarArrayCreate([0, SpeedHistorySize], varInteger);
    end;
    p:=VarArrayLock(History);
    try
      if IsNew then begin
        for j:=1 to SpeedHistorySize do
          p[j]:=-1;
        j:=1;
      end
      else begin
        j:=Round((Now - cardinal(p[0])/SecsPerDay)/RpcObj.RefreshInterval);
        if j = 0 then
          j:=1;
      end;
      p[0]:=integer(cardinal(Round(Now*SecsPerDay)));
      // Shift speed array
      if j < SpeedHistorySize then
        Move(p[1], p[j + 1], (SpeedHistorySize - j)*SizeOf(integer))
      else
        j:=SpeedHistorySize;

      while j > 0 do begin
        p[j]:=Speed;
        Dec(j);
      end;
      // Calc average speed
      res:=Speed;
      cnt:=1;
      for j:=2 to SpeedHistorySize do
        if p[j] < 0 then
          break
        else begin
          Inc(res, p[j]);
          Inc(cnt);
        end;

      Result:=res div cnt;
    finally
      VarArrayUnlock(History);
    end;
    if Result = 0 then
      VarClear(History);
  end;

var
  FilterIdx, OldId: integer;
  TrackerFilter, PathFilter, LabelFilter: string;
  UpSpeed, DownSpeed: double;
  DownCnt, SeedCnt, CompletedCnt, ActiveCnt, StoppedCnt, ErrorCnt, WaitingCnt, ft: integer;
  IsActive: boolean;
  Paths, Labels: TStringList;
  v: variant;
  FieldExists: array of boolean;
begin
  if gTorrents.Tag <> 0 then exit;
  if list = nil then begin
    ClearDetailsInfo;
    exit;
  end;
{
  for i:=1 to 1000 do begin
    t:=TJSONObject.Create;
    t.Integers['id']:=i + 10000;
    t.Strings['name']:=Format('ZName %d', [i]);
    t.Integers['status']:=TR_STATUS_STOPPED;
    t.Arrays['trackerStats']:=TJSONArray.Create;
    t.Floats['sizeWhenDone']:=0;
    t.Floats['leftUntilDone']:=0;
    t.Integers['rateDownload']:=0;
    t.Integers['rateUpload']:=0;
    list.Add(t);
  end;
}
  Paths:=TStringList.Create;
  Labels:=TStringList.Create;
  try
  Paths.Sorted:=True;
  Labels.Sorted:=True;
  OldId:=RpcObj.CurTorrentId;
  IsActive:=gTorrents.Enabled;
  gTorrents.Enabled:=True;
  lvFilter.Enabled:=True;
  gTorrents.Color:=clWindow;
  lvFilter.Color:=clWindow;
  edSearch.Enabled:=True;
  edSearch.Color:=clWindow;
  if not IsActive then
    ActiveControl:=gTorrents;

  for i:=0 to FTrackers.Count - 1 do
    FTrackers.Objects[i]:=nil;

  // Check fields' existence
  SetLength(FieldExists, FTorrents.ColCnt);
  if list.Count > 0 then begin
    t:=list[0] as TJSONObject;
    FieldExists[idxName]:=t.IndexOfName('name') >= 0;
    FieldExists[idxRatio]:=t.IndexOfName('uploadRatio') >= 0;
    FieldExists[idxTracker]:=t.IndexOfName('trackers') >= 0;
    FieldExists[idxPath]:=t.IndexOfName('downloadDir') >= 0;
    FieldExists[idxPriority]:=t.IndexOfName('bandwidthPriority') >= 0;
    FieldExists[idxQueuePos]:=t.IndexOfName('queuePosition') >= 0;
    FieldExists[idxSeedingTime]:=t.IndexOfName('secondsSeeding') >= 0;
    FieldExists[idxPrivate]:=t.IndexOfName('isPrivate') >= 0;
    FIeldExists[idxLabels]:=t.IndexOfName('labels') >= 0;
  end;

  UpSpeed:=0;
  DownSpeed:=0;
  DownCnt:=0;
  SeedCnt:=0;
  CompletedCnt:=0;
  ActiveCnt:=0;
  StoppedCnt:=0;
  ErrorCnt:=0;
  WaitingCnt:=0;

  FilterIdx:=lvFilter.Row;
  if VarIsNull(lvFilter.Items[0, FilterIdx]) then
    Dec(FilterIdx);
  if FilterIdx >= StatusFiltersCount then
    if not VarIsNull(lvFilter.Items[-1, FilterIdx]) then begin
      ft := Integer(lvFilter.Items[-2, FilterIdx]);
      if ft = 1 then
        PathFilter:=UTF8Encode(widestring(lvFilter.Items[-1, FilterIdx]))
      else
        LabelFilter:=UTF8Encode(widestring(lvFilter.Items[-1, FilterIdx]));
      FilterIdx:=fltAll;
    end
    else begin
      TrackerFilter:=UTF8Encode(widestring(lvFilter.Items[0, FilterIdx]));
      FilterIdx:=fltAll;
      i:=RPos('(', TrackerFilter);
      if i > 0 then
        TrackerFilter:=Trim(Copy(TrackerFilter, 1, i - 1));
    end;

  for i:=0 to FTorrents.Count - 1 do
    FTorrents[idxTag, i]:=0;

  for i:=0 to list.Count - 1 do begin
    StateImg:=-1;

    t:=list[i] as TJSONObject;
    id:=t.Integers['id'];
    ExistingRow:=FTorrents.Find(idxTorrentId, id, row);
    if not ExistingRow then
      FTorrents.InsertRow(row);

    FTorrents[idxTorrentId, row]:=t.Integers['id'];

    if FieldExists[idxName] then
      FTorrents[idxName, row]:=t.Strings['name'];

    j:=t.Integers['status'];
    if ExistingRow and (j = TR_STATUS_SEED) and (FTorrents[idxStatus, row] = TR_STATUS_DOWNLOAD) then
      DownloadFinished(UTF8Encode(widestring(FTorrents[idxName, row])));
    FTorrents[idxStatus, row]:=j;
    if j = TR_STATUS_CHECK_WAIT  then StateImg:=imgDownQueue else
    if j = TR_STATUS_CHECK  then StateImg:=imgDownQueue else
    if j = TR_STATUS_DOWNLOAD_WAIT  then StateImg:=imgDownQueue else
    if j = TR_STATUS_DOWNLOAD  then StateImg:=imgDown else
    if j = TR_STATUS_SEED_WAIT  then StateImg:=imgSeedQueue else
    if j = TR_STATUS_SEED  then StateImg:=imgSeed else
    if j = TR_STATUS_STOPPED  then StateImg:=imgDone;

    if GetTorrentError(t, j) <> '' then
      if t.Strings['errorString'] <> '' then
        StateImg:=imgError
      else
        if StateImg in [imgDown,imgSeed] then
          Inc(StateImg, 2);

    if j <> TR_STATUS_STOPPED then begin
      s:=GetTorrentError(t, j);
      if s <> '' then
        if t.Strings['errorString'] <> '' then
          StateImg:=imgError
        else
          if StateImg in [imgDown,imgSeed] then
            Inc(StateImg, 2);

      if RpcObj.RPCVersion >= 7 then begin
        s:='';
        if t.Arrays['trackerStats'].Count > 0 then
          with t.Arrays['trackerStats'].Objects[0] do begin
            if integer(Integers['announceState']) in [2, 3] then
              s:=sTrackerUpdating
            else
              if Booleans['hasAnnounced'] then
                if Booleans['lastAnnounceSucceeded'] then
                  s:=sTrackerWorking
                else
                  s:=TranslateString(UTF8Encode(Strings['lastAnnounceResult']), True);

            if s = 'Success' then
              s:=sTrackerWorking;
          end;
      end
      else
        s:=t.Strings['announceResponse'];
    end
    else
      s:='';
    FTorrents[idxTrackerStatus, row]:=UTF8Decode(s);

    if FTorrents[idxStatus, row] = TR_STATUS_CHECK then
      f:=t.Floats['recheckProgress']*100.0
    else begin
      f:=t.Floats['sizeWhenDone'];
      if f <> 0 then
        f:=(f - t.Floats['leftUntilDone'])*100.0/f;
      if StateImg = imgDone then
        if (t.Floats['leftUntilDone'] <> 0) or (t.Floats['sizeWhenDone'] = 0) then
          StateImg:=imgStopped
        else
          FTorrents[idxStatus, row]:=TR_STATUS_FINISHED;
    end;
    if f < 0 then
      f:=0;
    FTorrents[idxDone, row]:=Int(f*10.0)/10.0;
    FTorrents[idxStateImg, row]:=StateImg;
    GetTorrentValue(idxDownSpeed, 'rateDownload', vtInteger);
    j:=StoreSpeed(FTorrents.ItemPtrs[idxDownSpeedHistory, row]^, FTorrents[idxDownSpeed, row]);
    if FCalcAvg and (StateImg in [imgDown, imgDownError]) then
      FTorrents[idxDownSpeed, row]:=j;
    GetTorrentValue(idxUpSpeed, 'rateUpload', vtInteger);
    j:=StoreSpeed(FTorrents.ItemPtrs[idxUpSpeedHistory, row]^, FTorrents[idxUpSpeed, row]);
    if FCalcAvg and (StateImg in [imgSeed, imgSeedError]) then
      FTorrents[idxUpSpeed, row]:=j;

    GetTorrentValue(idxSize, 'totalSize', vtExtended);
    GetTorrentValue(idxSizeToDowload, 'sizeWhenDone', vtExtended);
    GetTorrentValue(idxSeeds, 'peersSendingToUs', vtInteger);
    GetTorrentValue(idxPeers, 'peersGettingFromUs', vtInteger);
    GetTorrentValue(idxETA, 'eta', vtInteger);
    v:=FTorrents[idxETA, row];
    if not VarIsNull(v) then
      if v < 0 then
        FTorrents[idxETA, row]:=MaxInt
      else begin
        f:=FTorrents[idxDownSpeed, row];
        if f > 0 then
          FTorrents[idxETA, row]:=Round(t.Floats['leftUntilDone']/f);
      end;
    GetTorrentValue(idxDownloaded, 'downloadedEver', vtExtended);
    GetTorrentValue(idxUploaded, 'uploadedEver', vtExtended);
    GetTorrentValue(idxSizeLeft, 'leftUntilDone', vtExtended);
    GetTorrentValue(idxAddedOn, 'addedDate', vtExtended);
    GetTorrentValue(idxCompletedOn, 'doneDate', vtExtended);
    GetTorrentValue(idxLastActive, 'activityDate', vtExtended);

    if RpcObj.RPCVersion >= 7 then begin
      if t.Arrays['trackerStats'].Count > 0 then
        with t.Arrays['trackerStats'].Objects[0] do begin
          FTorrents[idxSeedsTotal, row]:=Integers['seederCount'];
          FTorrents[idxLeechersTotal, row]:=Integers['leecherCount'];
        end
      else begin
        FTorrents[idxSeedsTotal, row]:=-1;
        FTorrents[idxLeechersTotal, row]:=-1;
      end;
      if t.Floats['metadataPercentComplete'] <> 1.0 then begin
        FTorrents[idxSize, row]:=-1;
        FTorrents[idxSizeToDowload, row]:=-1;
      end;
    end
    else begin
      GetTorrentValue(idxSeedsTotal, 'seeders', vtInteger);
      GetTorrentValue(idxLeechersTotal, 'leechers', vtInteger);
    end;
    if FieldExists[idxRatio] then begin
      f:=t.Floats['uploadRatio'];
      if f = -2 then
        f:=MaxInt;
      FTorrents[idxRatio, row]:=f;
    end
    else
      FTorrents[idxRatio, row]:=NULL;
    if FieldExists[idxSeedingTime] then
      FTorrents[idxSeedingTime, row]:=t.Integers['secondsSeeding']
    else
      FTorrents[idxSeedingTime, row]:=NULL;

    if RpcObj.RPCVersion >= 7 then begin
      if t.Arrays['trackerStats'].Count > 0 then
        s:=t.Arrays['trackerStats'].Objects[0].Strings['announce']
      else
        s:=sNoTracker;
    end
    else
      if FieldExists[idxTracker] then
        s:=UTF8Encode(t.Arrays['trackers'].Objects[0].Strings['announce'])
      else begin
        s:='';
        if VarIsEmpty(FTorrents[idxTracker, row]) then
          RpcObj.RequestFullInfo:=True;
      end;

    if s <> '' then begin
      j:=Pos('://', s);
      if j > 0 then
        s:=Copy(s, j + 3, MaxInt);
      j:=Pos('/', s);
      if j > 0 then
        s:=Copy(s, 1, j - 1);
      j:=Pos('.', s);
      if j > 0 then begin
        ss:=Copy(s, 1, j - 1);
        if AnsiCompareText(ss, 'bt') = 0 then
          System.Delete(s, 1, 3)
        else
          if (Length(ss) = 3) and (AnsiCompareText(Copy(ss, 1, 2), 'bt') = 0) and (ss[3] in ['1'..'9']) then
            System.Delete(s, 1, 4);
      end;
      j:=Pos(':', s);
      if j > 0 then
        System.Delete(s, j, MaxInt);
      FTorrents[idxTracker, row]:=UTF8Decode(s);
    end;

    if FieldExists[idxPath] then
      FTorrents[idxPath, row]:=UTF8Decode(ExcludeTrailingPathDelimiter(UTF8Encode(t.Strings['downloadDir'])))
    else
      if VarIsEmpty(FTorrents[idxPath, row]) then
        RpcObj.RequestFullInfo:=True;

    if not VarIsEmpty(FTorrents[idxPath, row]) then begin
      s:=UTF8Encode(widestring(FTorrents[idxPath, row]));
      j:=Paths.IndexOf(s);
      if j < 0 then
        Paths.AddObject(s, TObject(1))
      else
        Paths.Objects[j]:=TObject(PtrInt(Paths.Objects[j]) + 1);
    end;

    if FieldExists[idxPriority] then
      FTorrents[idxPriority, row]:=t.Integers['bandwidthPriority'];

    if FieldExists[idxQueuePos] then begin
      j:=t.Integers['queuePosition'];
      if FTorrents[idxStatus, row] = TR_STATUS_FINISHED then
        Inc(j, FinishedQueue);
      FTorrents[idxQueuePos, row]:=j;
    end;

    if FieldExists[idxPrivate] then
      FTorrents[idxPrivate, row]:=t.Integers['isPrivate'];

    if FieldExists[idxLabels] then begin
      a := t.Arrays['labels'];
      s := '';
      for j:=0 to a.Count-1 do begin
        ss := UTF8Encode(widestring(a.Strings[j]));
        if j > 0 then s := s + ', ';
        s := s + ss;
        p := Labels.IndexOf(ss);
        if p < 0 then
          Labels.AddObject(ss, TObject(1))
        else
          Labels.Objects[p]:=TObject(PtrInt(Labels.Objects[p]) + 1);
      end;
      FTorrents[idxLabels, row] := s;
    end;

    DownSpeed:=DownSpeed + FTorrents[idxDownSpeed, row];
    UpSpeed:=UpSpeed + FTorrents[idxUpSpeed, row];

    FTorrents[idxTag, row]:=1;
  end;

  i:=0;
  while i < FTorrents.Count do
    if FTorrents[idxTag, i] = 0 then
      FTorrents.Delete(i)
    else
      Inc(i);

  gTorrents.Items.BeginUpdate;
  try
    for i:=0 to gTorrents.Items.Count - 1 do
      gTorrents.Items[idxTag, i]:=0;

    gTorrents.Items.Sort(idxTorrentId);

    for i:=0 to FTorrents.Count - 1 do begin
      IsActive:=(FTorrents[idxDownSpeed, i] <> 0) or (FTorrents[idxUpSpeed, i] <> 0);
      if IsActive then
        Inc(ActiveCnt);

      j:=FTorrents[idxStatus, i];
      if j = TR_STATUS_DOWNLOAD then
        Inc(DownCnt)
      else
      if j = TR_STATUS_SEED then begin
        Inc(SeedCnt);
        Inc(CompletedCnt);
      end
      else
      if j = TR_STATUS_FINISHED then
        Inc(CompletedCnt);

      if (j = TR_STATUS_CHECK) or (j = TR_STATUS_CHECK_WAIT) or (j = TR_STATUS_DOWNLOAD_WAIT) then
        inc(WaitingCnt);

      StateImg:=FTorrents[idxStateImg, i];
      if StateImg in [imgStopped, imgDone] then
        Inc(StoppedCnt)
      else
        if StateImg in [imgDownError, imgSeedError, imgError] then
          Inc(ErrorCnt);

      if not VarIsEmpty(FTorrents[idxTracker, i]) then begin
        s:=UTF8Encode(widestring(FTorrents[idxTracker, i]));
        j:=FTrackers.IndexOf(s);
        if j < 0 then
          j:=FTrackers.Add(s);
        FTrackers.Objects[j]:=TObject(ptruint(FTrackers.Objects[j]) + 1);
        if (TrackerFilter <> '') and (TrackerFilter <> s) then
          continue;
      end;

      if (PathFilter <> '') and not VarIsEmpty(FTorrents[idxPath, i]) and (UTF8Decode(PathFilter) <> FTorrents[idxPath, i]) then
        continue;

      if (LabelFilter <> '') and not VarIsEmpty(FTorrents[idxLabels, i]) then begin
        if not AnsiContainsStr(String(FTorrents[idxLabels, i]), LabelFilter) then
          continue;
      end;

      case FilterIdx of
        fltActive:
          if not IsActive then
            continue;
        fltInactive:
          if (IsActive=true) or ((StateImg in [imgStopped, imgDone])=true) then // PETROV
            continue;
        fltDown:
          if FTorrents[idxStatus, i] <> TR_STATUS_DOWNLOAD then
            continue;
        fltDone:
          if (StateImg <> imgDone) and (FTorrents[idxStatus, i] <> TR_STATUS_SEED) then
            continue;
        fltStopped:
          if not (StateImg in [imgStopped, imgDone]) then
            continue;
        fltError:
          if not (StateImg in [imgDownError, imgSeedError, imgError]) then
            continue;
        fltWaiting:
            if (FTorrents[idxStatus, i] <> TR_STATUS_CHECK) and (FTorrents[idxStatus, i] <> TR_STATUS_CHECK_WAIT) and (FTorrents[idxStatus, i] <> TR_STATUS_DOWNLOAD_WAIT)then
              continue;
      end;

      if edSearch.Text <> '' then
        if UTF8Pos(UTF8UpperCase(edSearch.Text), UTF8UpperCase(UTF8Encode(widestring(FTorrents[idxName, i])))) = 0 then
          continue;

      if not gTorrents.Items.Find(idxTorrentId, FTorrents[idxTorrentId, i], row) then
        gTorrents.Items.InsertRow(row);
      for j:=-TorrentsExtraColumns to FTorrents.ColCnt - 1 do
        if (j <> idxDownSpeedHistory) and (j <> idxUpSpeedHistory) then
          gTorrents.Items[j, row]:=FTorrents[j, i];
      gTorrents.Items[idxTag, row]:=1;
    end;

    i:=0;
    while i < gTorrents.Items.Count do
      if gTorrents.Items[idxTag, i] = 0 then
        gTorrents.Items.Delete(i)
      else
        Inc(i);

    gTorrents.Sort;
    if gTorrents.Items.Count > 0 then begin
      if OldId <> 0 then begin
        i:=gTorrents.Items.IndexOf(idxTorrentId, OldId);
        if i >= 0 then
          gTorrents.Row:=i
        else
          if FFilterChanged then
            OldId:=0;
      end;
      if OldId = 0 then
        gTorrents.Row:=0;
    end;
    FFilterChanged:=False;
  finally
    gTorrents.Items.EndUpdate;
  end;
  gTorrentsClick(nil);

  crow:=-1;
  lvFilter.Items.BeginUpdate;
  try
    lvFilter.Items[0, 0]:=UTF8Decode(Format('%s (%d)', [SAll, list.Count]));
    lvFilter.Items[0, 1]:=UTF8Decode(Format('%s (%d)', [SDownloading, DownCnt]));
    lvFilter.Items[0, 2]:=UTF8Decode(Format('%s (%d)', [SCompleted, CompletedCnt]));
    lvFilter.Items[0, 3]:=UTF8Decode(Format('%s (%d)', [SActive, ActiveCnt]));
    lvFilter.Items[0, 4]:=UTF8Decode(Format('%s (%d)', [SInactive, FTorrents.Count - ActiveCnt - StoppedCnt]));
    lvFilter.Items[0, 5]:=UTF8Decode(Format('%s (%d)', [sStopped, StoppedCnt]));
    lvFilter.Items[0, 6]:=UTF8Decode(Format('%s (%d)', [sErrorState, ErrorCnt]));
    lvFilter.Items[0, 7]:=UTF8Decode(Format('%s (%d)', [sWaiting, WaitingCnt]));

    j:=StatusFiltersCount;

    if acFolderGrouping.Checked then begin
      lvFilter.Items[0, j]:=NULL;
      Inc(j);

      for i:=0 to Paths.Count - 1 do begin
        s:=ExtractFileName(Paths[i]);
        for row:=StatusFiltersCount + 1 to j - 1 do
          if ExtractFileName(UTF8Encode(widestring(lvFilter.Items[-1, row]))) = s then begin
            s:=Paths[i];
            lvFilter.Items[0, row]:=UTF8Decode(Format('%s (%d)', [UTF8Encode(widestring(lvFilter.Items[-1, row])), ptruint(Paths.Objects[row - StatusFiltersCount - 1])]));
          end;
        lvFilter.Items[ 0, j]:=UTF8Decode(Format('%s (%d)', [s, ptruint(Paths.Objects[i])]));
        lvFilter.Items[-1, j]:=UTF8Decode(Paths[i]);
        lvFilter.Items[-2, j]:=1;
        if Paths[i] = PathFilter then
          crow:=j;
        Inc(j);
      end;
    end;

    if acLabelGrouping.Checked then begin
      lvFilter.Items[0, j]:=NULL;
      Inc(j);

      for i:=0 to Labels.Count - 1 do begin
        lvFilter.Items[0, j]:=UTF8Decode(Format('%s (%d)', [Labels[i], ptruint(Labels.Objects[i])]));
        lvFilter.Items[-1, j]:=UTF8Decode(Labels[i]);
        lvFilter.Items[-2, j]:=2;
        if Labels[i] = LabelFilter then
          crow:=j;
        Inc(j);
      end;

    end;

    row:=j;

    if acTrackerGrouping.Checked then begin
      if not VarIsNull(lvFilter.Items[0, row - 1]) then begin
        lvFilter.Items[0, row]:=NULL;
        Inc(row);
      end;

      i:=0;
      while i < FTrackers.Count do begin
        j:=ptruint(FTrackers.Objects[i]);
        if j > 0 then begin
          lvFilter.Items[ 0, row]:=UTF8Decode(Format('%s (%d)', [FTrackers[i], j]));
          lvFilter.Items[-1, row]:=NULL;
          lvFilter.Items[-2, row]:=3;
          if FTrackers[i] = TrackerFilter then
            crow:=row;
          Inc(i);
          Inc(row);
        end
        else
          FTrackers.Delete(i);
      end;
    end;

    lvFilter.Items.RowCnt:=row;
  finally
    lvFilter.Items.EndUpdate;
  end;
  if crow >= 0 then
    lvFilter.Row:=crow
  else
    if lvFilter.Row >= StatusFiltersCount then
      lvFilterClick(nil);

  CheckStatus;

  s := GetHumanSize(FCurDownSpeedLimit*1024,2,'');
  if s = '' then s := Format(SUnlimited,[]) else s := s + '/s';
  ss := GetHumanSize(FCurUpSpeedLimit*1024,2,'');
  if ss = '' then ss := Format(SUnlimited,[]) else ss := ss + '/s';
  StatusBar.Panels[1].Text:=Format(sDownSpeed, [GetHumanSize(DownSpeed, 1)]) + ' (' + s + ')';
  StatusBar.Panels[2].Text:=Format(sUpSpeed, [GetHumanSize(UpSpeed, 1)]) + ' (' + ss + ')';

{$ifndef LCLcarbon}
  // There is memory leak in TTrayIcon implementation for Mac.
  // Disable tray icon update for Mac.
  TrayIcon.Hint:=Format(sDownloadingSeeding,
        [RpcObj.InfoStatus, LineEnding, DownCnt, SeedCnt, LineEnding, StatusBar.Panels[1].Text, StatusBar.Panels[2].Text]);
{$endif LCLcarbon}
  finally
    Paths.Free;
  end;
  DetailsUpdated;
end;

procedure TMainForm.FillPeersList(list: TJSONArray);
var
  i, j, row: integer;
  port: integer;
  d: TJSONData;
  p: TJSONObject;
  ip, s: string;
  hostinfo: PHostEntry;
  opt: TResolverOptions;
  WasEmpty: boolean;
begin
  if list = nil then begin
    ClearDetailsInfo;
    exit;
  end;
  WasEmpty:=lvPeers.Items.Count = 0;
  lvPeers.Items.BeginUpdate;
  try
    lvPeers.Enabled:=True;
    lvPeers.Color:=clWindow;
    if FResolver = nil then begin
      opt:=[];
      if acResolveHost.Checked then
        Include(opt, roResolveIP);
      if acResolveCountry.Checked then
        Include(opt, roResolveCountry);
      if opt <> [] then
        FResolver:=TIpResolver.Create(GetGeoIpDatabase, opt);
    end;

    for i:=0 to lvPeers.Items.Count - 1 do
      lvPeers.Items[idxPeerTag, i]:=0;

    lvPeers.Items.Sort(idxPeerIP);
    for i:=0 to list.Count - 1 do begin
      d:=list[i];
      if not (d is TJSONObject) then continue;
      p:=d as TJSONObject;
      ip:=p.Strings['address'];
      if p.IndexOfName('port') >= 0 then
        port:=p.Integers['port']
      else
        port:=0;

      s:=ip + ':' + IntToStr(port);
      if not lvPeers.Items.Find(idxPeerIP, s, row) then
        lvPeers.Items.InsertRow(row);
      lvPeers.Items[idxPeerIP, row]:=s;
      lvPeers.Items[idxPeerPort, row]:=port;

      if FResolver <> nil then
        hostinfo:=FResolver.Resolve(ip)
      else
        hostinfo:=nil;
      if hostinfo <> nil then
        lvPeers.Items[idxPeerHost, row]:=hostinfo^.HostName
      else
        lvPeers.Items[idxPeerHost, row]:=ip;

      if hostinfo <> nil then
        lvPeers.Items[idxPeerCountry, row]:=hostinfo^.CountryName
      else
        lvPeers.Items[idxPeerCountry, row]:='';

      if acShowCountryFlag.Checked and (hostinfo <> nil) then begin
        if hostinfo^.ImageIndex = 0 then
          hostinfo^.ImageIndex:=GetFlagImage(hostinfo^.CountryCode);
        j:=hostinfo^.ImageIndex
      end
      else
        j:=0;
      lvPeers.Items[idxPeerCountryImage, row]:=j;
      lvPeers.Items[idxPeerClient, row]:=p.Strings['clientName'];
      lvPeers.Items[idxPeerFlags, row]:=p.Strings['flagStr'];
      lvPeers.Items[idxPeerDone, row]:=p.Floats['progress'];

      if p.IndexOfName('rateToClient') >= 0 then
        lvPeers.Items[idxPeerDownSpeed, row]:=p.Integers['rateToClient'];
      if p.IndexOfName('rateToPeer') >= 0 then
        lvPeers.Items[idxPeerUpSpeed, row]:=p.Integers['rateToPeer'];

      lvPeers.Items[idxPeerTag, row]:=1;
    end;

    i:=0;
    while i < lvPeers.Items.Count do
      if lvPeers.Items[idxPeerTag, i] = 0 then
        lvPeers.Items.Delete(i)
      else
        Inc(i);
    lvPeers.Sort;
    if WasEmpty and (lvPeers.Items.Count > 0) then
      lvPeers.Row:=0;
  finally
    lvPeers.Items.EndUpdate;
  end;
  DetailsUpdated;
end;

function TMainForm.GetFilesCommonPath(files: TJSONArray): string;
var
  i: integer;
  d: TJSONData;
  f: TJSONObject;
  s: string;
begin
  Result:='';
  for i:=0 to files.Count - 1 do begin
    d:=files[i];
    if not (d is TJSONObject) then continue;
    f:=d as TJSONObject;
    s:=UTF8Encode(f.Strings['name']);
    if i = 0 then
      Result:=ExtractFilePath(s)
    else begin
      while True do begin
        if Result = '' then
          exit;
        if Copy(s, 1, Length(Result)) <> Result then begin
          SetLength(Result, Length(Result) - 1);
          Result:=ExtractFilePath(Result);
        end
        else
          break;
      end;
    end;
  end;
end;

procedure TMainForm.InternalRemoveTorrent(const Msg, MsgMulti: string; RemoveLocalData: boolean);
var
  args: TJSONObject;
  ids: variant;
  s: string;
  i, j, id: integer;
begin
  if gTorrents.Items.Count = 0 then exit;
  gTorrents.Tag:=1;
  try
    gTorrents.EnsureSelectionVisible;
    ids:=GetSelectedTorrents;
    if gTorrents.SelCount < 2 then
      s:=Format(Msg, [UTF8Encode(widestring(gTorrents.Items[idxName, gTorrents.Items.IndexOf(idxTorrentId, ids[0])]))])
    else
      s:=Format(MsgMulti, [gTorrents.SelCount]);

    s:=TranslateString(s, True);
    if MessageDlg('', s, mtConfirmation, mbYesNo, 0, mbNo) <> mrYes then exit;
  finally
    gTorrents.Tag:=0;
  end;
  args:=TJSONObject.Create;
  if RemoveLocalData then
    args.Add('delete-local-data', TJSONIntegerNumber.Create(1));

  if TorrentAction(ids, 'torrent-remove', args) then begin
    with gTorrents do begin
      BeginUpdate;
      try
        i:=0;
        while i < Items.Count do begin
          id:=Items[idxTorrentId, i];
          for j:=0 to VarArrayHighBound(ids, 1) do
            if id = ids[j] then begin
              Items.Items[idxDeleted, i]:=1;
              break;
            end;
          Inc(i);
        end;
      finally
        EndUpdate;
      end;
    end;

    if RemoveLocalData then
      RpcObj.RefreshNow:=RpcObj.RefreshNow + [rtSession];
  end;
end;

function TMainForm.IncludeProperTrailingPathDelimiter(const s: string): string;
var
  i: integer;
  d: char;
begin
  Result:=s;
  if Result = '' then exit;
  d:='/';
  for i:=1 to Length(Result) do
    if Result[i] in ['/','\'] then begin
      d:=Result[i];
      break;
    end;

  if Result[Length(Result)] <> d then
    Result:=Result + d;
end;

procedure TMainForm.FillFilesList(ATorrentId: integer; list, priorities, wanted: TJSONArray; const DownloadDir: WideString);
begin
  if lvFiles.Tag <> 0 then exit;
  if (list = nil) or (priorities = nil) or (wanted = nil) then begin
    ClearDetailsInfo;
    exit;
  end;

  lvFiles.Enabled:=True;
  lvFiles.Color  :=clWindow;
  FFilesTree.DownloadDir:=UTF8Encode(DownloadDir);
  FFilesTree.FillTree(ATorrentId, list, priorities, wanted);
  tabFiles.Caption:=Format('%s (%d)', [FFilesCapt, list.Count]);
  DetailsUpdated;
end;

procedure TMainForm.FillGeneralInfo(t: TJSONObject);
var
  i, j, idx: integer;
  s: string;
  tr: string;
  f: double;
  ja: TJSONArray;
begin
  if (gTorrents.Items.Count = 0) or (t = nil) then begin
    ClearDetailsInfo;
    exit;
  end;
  idx:=gTorrents.Items.IndexOf(idxTorrentId, t.Integers['id']);
  if idx = -1 then begin
    ClearDetailsInfo;
    exit;
  end;

  txDownProgress.Caption:=Format('%.1f%%', [double(gTorrents.Items[idxDone, idx])]);
  txDownProgress.AutoSize:=True;
  if RpcObj.RPCVersion >= 5 then
    s:=t.Strings['pieces']
  else
    s:='';
  ProcessPieces(s, t.Integers['pieceCount'], gTorrents.Items[idxDone, idx]);

  panTransfer.ChildSizing.Layout:=cclNone;
  txStatus.Caption:=GetTorrentStatus(idx);
  tr:=GetTorrentError(t, gTorrents.Items[idxStatus, idx]);
  txError.Constraints.MinWidth:=400;
  if Ini.ReadBool('Translation', 'TranslateMsg', True) then
    txError.Caption:=TranslateString(tr, True)
  else
      txError.Caption:=tr;

  i:=t.Integers['eta'];
  f:=gTorrents.Items[idxDownSpeed, idx];
  if f > 0 then
    i:=Round(t.Floats['leftUntilDone']/f);
  //txRemaining.Caption:=EtaToString(i);
  txRemaining.Caption:=EtaToString(i)+' ('+GetHumanSize(t.Floats['leftUntilDone'])+')';
  txDownloaded.Caption:=GetHumanSize(t.Floats['downloadedEver']);
  txUploaded.Caption:=GetHumanSize(t.Floats['uploadedEver']);

  f:=t.Floats['pieceSize'];
  if f > 0 then
    i:=Round(t.Floats['corruptEver']/f)
  else
    i:=0;
  txWasted.Caption:=Format(sHashfails, [GetHumanSize(t.Floats['corruptEver']), i]);
  s:=GetHumanSize(gTorrents.Items[idxDownSpeed, idx], 1)+sPerSecond;
  if t.IndexOfName('secondsDownloading') >= 0 then begin
    f:=t.Integers['secondsDownloading'];
    if f > 0 then
      s:=Format('%s (%s: %s)', [s, SAverage, GetHumanSize(t.Floats['downloadedEver']/f, 1) + sPerSecond]);
  end;
  txDownSpeed.Caption:=s;
  txUpSpeed.Caption:=GetHumanSize(gTorrents.Items[idxUpSpeed, idx], 1)+sPerSecond;
  s:=RatioToString(t.Floats['uploadRatio']);
  if t.IndexOfName('secondsSeeding') >= 0 then begin
    i:=t.Integers['secondsSeeding'];
    if i > 0 then
      s:=Format('%s (%s)', [s, EtaToString(i)]);
  end;
  txRatio.Caption:=s;

  if RpcObj.RPCVersion < 5 then
  begin
    // RPC versions prior to v5
    j:=t.Integers['downloadLimitMode'];
    if j = TR_SPEEDLIMIT_GLOBAL then
      s:='-'
    else begin
      i:=t.Integers['downloadLimit'];
      if (i < 0) or (j = TR_SPEEDLIMIT_UNLIMITED) then
        s:=Utf8Encode(WideString(WideChar($221E)))
      else
        s:=GetHumanSize(i*1024)+sPerSecond;
    end;
    txDownLimit.Caption:=s;
    j:=t.Integers['uploadLimitMode'];
    if j = TR_SPEEDLIMIT_GLOBAL then
      s:='-'
    else begin
      i:=t.Integers['uploadLimit'];
      if (i < 0) or (j = TR_SPEEDLIMIT_UNLIMITED) then
        s:=Utf8Encode(WideString(WideChar($221E)))
      else
        s:=GetHumanSize(i*1024)+sPerSecond;
    end;
    txUpLimit.Caption:=s;
  end else begin
    // RPC version 5
    if t.Booleans['downloadLimited'] then
    begin
      i:=t.Integers['downloadLimit'];
      if i < 0 then
        s:=Utf8Encode(WideString(WideChar($221E)))
      else
        s:=GetHumanSize(i*1024)+sPerSecond;
    end else s:='-';
    txDownLimit.Caption:=s;

    if t.Booleans['uploadLimited'] then
    begin
      i:=t.Integers['uploadLimit'];
      if i < 0 then
        s:=Utf8Encode(WideString(WideChar($221E)))
      else
        s:=GetHumanSize(i*1024)+sPerSecond;
    end else s:='-';
    txUpLimit.Caption:=s;
  end;

  if RpcObj.RPCVersion >= 7 then
    with t.Arrays['trackerStats'] do begin
      if Count > 0 then begin
        if integer(Objects[0].Integers['announceState']) in [2, 3] then
          f:=1
        else
          f:=Objects[0].Floats['nextAnnounceTime'];
      end
      else
        f:=0;
    end
  else
    f:=t.Floats['nextAnnounceTime'];
  if f = 0 then
    s:='-'
  else
  if f = 1 then
    s:=sUpdating
  else
    s:=TorrentDateTimeToString(Trunc(f),FFromNow);
  txTrackerUpdate.Caption:=s;
  txTrackerUpdate.Hint:=TorrentDateTimeToString(Trunc(f),not(FFromNow));
  txTracker.Caption:=UTF8Encode(widestring(gTorrents.Items[idxTracker, idx]));
  if RpcObj.RPCVersion >= 7 then
    if t.Arrays['trackerStats'].Count > 0 then
      i:=t.Arrays['trackerStats'].Objects[0].Integers['seederCount']
    else
      i:=-1
  else
    i:=t.Integers['seeders'];
  s:=GetSeedsText(t.Integers['peersSendingToUs'], i);
  txSeeds.Caption:=StringReplace(s, '/', ' ' + sOf + ' ', []) + ' '+ sConnected;
  if RpcObj.RPCVersion >= 7 then
    if t.Arrays['trackerStats'].Count > 0 then
      i:=t.Arrays['trackerStats'].Objects[0].Integers['leecherCount']
    else
      i:=-1
  else
    i:=t.Integers['leechers'];
  s:=GetPeersText(t.Integers['peersGettingFromUs'], -1, i);
  s:=StringReplace(s, ' ', ' '+ sConnected +' ', []);
  s:=StringReplace(s, '/', ' ' + sOf + ' ', []);
  txPeers.Caption:=StringReplace(s, ')', ' '+ sInSwarm+ ')', []);
  txMaxPeers.Caption:=t.Strings['maxConnectedPeers'];
  txLastActive.Caption:=TorrentDateTimeToString(Trunc(t.Floats['activityDate']),FFromNow);
  txLastActive.Hint:=TorrentDateTimeToString(Trunc(t.Floats['activityDate']),Not(FFromNow));
  panTransfer.ChildSizing.Layout:=cclLeftToRightThenTopToBottom;

  if RpcObj.RPCVersion >= 7 then
    txMagnetLink.Text := t.Strings['magnetLink'];


  panGeneralInfo.ChildSizing.Layout:=cclNone;

  s:=UTF8Encode(widestring(gTorrents.Items[idxName, idx]));
  if RpcObj.RPCVersion >= 4 then
    s:=IncludeProperTrailingPathDelimiter(UTF8Encode(t.Strings['downloadDir'])) + s;
  txTorrentName.Caption:=s;
  s:=Trim(UTF8Encode(t.Strings['creator']));
  if s <> '' then
    s:=' by ' + s;
  txCreated.Caption:=TorrentDateTimeToString(Trunc(t.Floats['dateCreated']),FFromNow) + s;
  txCreated.Hint   :=TorrentDateTimeToString(Trunc(t.Floats['dateCreated']),Not(FFromNow)) + s;
  if gTorrents.Items[idxSize, idx] >= 0 then begin
    txTotalSize.Caption:=Format(sDone, [GetHumanSize(t.Floats['totalSize']), GetHumanSize(t.Floats['sizeWhenDone'] - t.Floats['leftUntilDone'])]);
    if t.Floats['totalSize'] = t.Floats['haveValid'] then
      i:=t.Integers['pieceCount']
    else
      i:=Trunc(t.Floats['haveValid']/(t.Floats['pieceSize'] + 0.00000001)); // division by 0

    txPieces.Caption:=Format(sHave, [t.Integers['pieceCount'], GetHumanSize(t.Floats['pieceSize']), i]);
  end
  else begin
    txTotalSize.Caption:='?';
    txPieces.Caption:='?';
  end;

  txHash.Caption:=t.Strings['hashString'];
  txComment.Caption:=UTF8Encode(t.Strings['comment']);
  if (AnsiCompareText(Copy(txComment.Caption, 1, 7), 'http://') = 0)
    or (AnsiCompareText(Copy(txComment.Caption, 1, 8), 'https://') = 0)
  then begin
    if not Assigned(txComment.OnClick) then begin
      txComment.OnClick:=@UrlLabelClick;
      txComment.Cursor:=crHandPoint;
      txComment.Font.Color:=clBlue;
      txComment.Font.Style:=[fsUnderline];
    end;
  end
  else begin
    if Assigned(txComment.OnClick) then begin
      txComment.OnClick:=nil;
      txComment.Cursor:=crDefault;
      txComment.ParentFont:=True;
    end;
  end;
  txAddedOn.Caption:=TorrentDateTimeToString(Trunc(t.Floats['addedDate']),FFromNow);
  txAddedOn.Hint:=TorrentDateTimeToString(Trunc(t.Floats['addedDate']),Not(FFromNow));
  txCompletedOn.Caption:=TorrentDateTimeToString(Trunc(t.Floats['doneDate']),FFromNow);
  txCompletedOn.Hint:=TorrentDateTimeToString(Trunc(t.Floats['doneDate']),Not(FFromNow));
  panGeneralInfo.ChildSizing.Layout:=cclLeftToRightThenTopToBottom;

  if t.IndexOfName('labels') >= 0 then begin
    ja:=t.Arrays['labels'];
    s:='';
    for i:=0 to ja.Count-1 do begin
      if i > 0 then begin
        s := s + ', ';
      end;
      s := s + ja.Strings[i];
    end;
    txLabels.Caption := s;
  end;
  DetailsUpdated;
end;

procedure TMainForm.FillTrackersList(TrackersData: TJSONObject);
var
  i, tidx, row: integer;
  id: integer;
  d: TJSONData;
  t: TJSONObject;
  f: double;
  s: string;
  Trackers, TrackerStats: TJSONArray;
  WasEmpty, NoInfo: boolean;
begin
  if TrackersData = nil then begin
    ClearDetailsInfo;
    exit;
  end;
  Trackers:=TrackersData.Arrays['trackers'];
  if RpcObj.RPCVersion >= 7 then
    TrackerStats:=TrackersData.Arrays['trackerStats']
  else
    TrackerStats:=nil;
  tidx:=gTorrents.Items.IndexOf(idxTorrentId, TrackersData.Integers['id']);
  if tidx = -1 then begin
    ClearDetailsInfo;
    exit;
  end;
  i:=gTorrents.Items[idxStatus, tidx];
  NoInfo:=(i = TR_STATUS_STOPPED) or (i = TR_STATUS_FINISHED);
  WasEmpty:=lvTrackers.Items.Count = 0;
  lvTrackers.Items.BeginUpdate;
  try
    lvTrackers.Enabled:=True;
    lvTrackers.Color:=clWindow;
    for i:=0 to lvTrackers.Items.Count - 1 do
      lvTrackers.Items[idxTrackerTag, i]:=0;

    lvTrackers.Items.Sort(idxTrackerID);
    for i:=0 to Trackers.Count - 1 do begin
      d:=Trackers[i];
      if not (d is TJSONObject) then continue;
      t:=d as TJSONObject;
      if t.IndexOfName('id') >= 0 then
        id:=t.Integers['id']
      else
        id:=i;
      if not lvTrackers.Items.Find(idxTrackerID, id, row) then
        lvTrackers.Items.InsertRow(row);
      lvTrackers.Items[idxTrackerID, row]:=id;
      lvTrackers.Items[idxTrackersListName, row]:=t.Strings['announce'];
      if NoInfo then begin
        lvTrackers.Items[idxTrackersListStatus, row]:=NULL;
        lvTrackers.Items[idxTrackersListSeeds, row]:=NULL;
        f:=0;
      end
      else
        if TrackerStats <> nil then begin
          f:=0;
          if i < TrackerStats.Count then
            with TrackerStats.Objects[i] do begin
              s:='';
              if integer(Integers['announceState']) in [2, 3] then
                s:=sTrackerUpdating
              else
                if Booleans['hasAnnounced'] then
                  if Booleans['lastAnnounceSucceeded'] then
                    s:=sTrackerWorking
                  else
                    s:=TranslateString(UTF8Encode(Strings['lastAnnounceResult']), True);

              if s = 'Success' then
                s:=sTrackerWorking;

              lvTrackers.Items[idxTrackersListStatus, row]:=UTF8Decode(s); // UTF8Decode
              lvTrackers.Items[idxTrackersListSeeds, row]:=Integers['seederCount'];

              if integer(Integers['announceState']) in [2, 3] then
                f:=1
              else
                f:=Floats['nextAnnounceTime'];
            end;
        end
        else begin
          if i = 0 then begin
            lvTrackers.Items[idxTrackersListStatus, row]:=gTorrents.Items[idxTrackerStatus, tidx];
            lvTrackers.Items[idxTrackersListSeeds, row]:=gTorrents.Items[idxSeedsTotal, tidx];
          end;
          f:=TrackersData.Floats['nextAnnounceTime'];
        end;

      if f > 1 then begin
        f:=(UnixToDateTime(Trunc(f)) + GetTimeZoneDelta - Now)*SecsPerDay;
        if f < 0 then
          f:=0;
      end;
      if (TrackerStats <> nil) or (i = 0) then
        lvTrackers.Items[idxTrackersListUpdateIn, row]:=f;

      lvTrackers.Items[idxTrackerTag, row]:=1;
    end;

    i:=0;
    while i < lvTrackers.Items.Count do
      if lvTrackers.Items[idxTrackerTag, i] = 0 then
        lvTrackers.Items.Delete(i)
      else
        Inc(i);

    lvTrackers.Sort;
    if WasEmpty and (lvTrackers.Items.Count > 0) then
      lvTrackers.Row:=0;
  finally
    lvTrackers.Items.EndUpdate;
  end;
  DetailsUpdated;
end;

procedure TMainForm.FillSessionInfo(s: TJSONObject);
var
  d, u: integer;
begin
{$ifdef LCLcarbon}
  TrayIcon.Tag:=0;
{$endif LCLcarbon}
  if RpcObj.RPCVersion < 14 then begin
    TR_STATUS_STOPPED:=TR_STATUS_STOPPED_1;
    TR_STATUS_CHECK_WAIT:=TR_STATUS_CHECK_WAIT_1;
    TR_STATUS_CHECK:=TR_STATUS_CHECK_1;
    TR_STATUS_DOWNLOAD_WAIT:=-1;
    TR_STATUS_DOWNLOAD:=TR_STATUS_DOWNLOAD_1;
    TR_STATUS_SEED_WAIT:=-1;
    TR_STATUS_SEED:=TR_STATUS_SEED_1;
  end
  else begin
    TR_STATUS_STOPPED:=TR_STATUS_STOPPED_2;
    TR_STATUS_CHECK_WAIT:=TR_STATUS_CHECK_WAIT_2;
    TR_STATUS_CHECK:=TR_STATUS_CHECK_2;
    TR_STATUS_DOWNLOAD_WAIT:=TR_STATUS_DOWNLOAD_WAIT_2;
    TR_STATUS_DOWNLOAD:=TR_STATUS_DOWNLOAD_2;
    TR_STATUS_SEED_WAIT:=TR_STATUS_SEED_WAIT_2;
    TR_STATUS_SEED:=TR_STATUS_SEED_2;
  end;

  UpdateUIRpcVersion(RpcObj.RPCVersion);

  if RpcObj.RPCVersion >= 5 then begin
{$ifdef LCLcarbon}
    if acAltSpeed.Checked <> (s.Integers['alt-speed-enabled'] <> 0) then
      TrayIcon.Tag:=1;
{$endif LCLcarbon}
    acAltSpeed.Checked:=s.Integers['alt-speed-enabled'] <> 0;
    acUpdateBlocklist.Tag:=s.Integers['blocklist-enabled'];
    acUpdateBlocklist.Enabled:=acUpdateBlocklist.Tag <> 0;
  end;
  if s.IndexOfName('download-dir-free-space') >= 0 then
    StatusBar.Panels[3].Text:=Format(SFreeSpace, [GetHumanSize(s.Floats['download-dir-free-space'])]);

  if (RpcObj.RPCVersion >= 5) and acAltSpeed.Checked then begin
    d:=s.Integers['alt-speed-down'];
    u:=s.Integers['alt-speed-up']
  end
  else begin
    if s.Integers['speed-limit-down-enabled'] <> 0 then
      d:=s.Integers['speed-limit-down']
    else
      d:=-1;
    if s.Integers['speed-limit-up-enabled'] <> 0 then
      u:=s.Integers['speed-limit-up']
    else
      u:=-1;
  end;
{$ifdef LCLcarbon}
  UpdateUI;
{$endif LCLcarbon}
  if (FCurDownSpeedLimit <> d) or (FCurUpSpeedLimit <> u) then begin
    FCurDownSpeedLimit:=d;
    FCurUpSpeedLimit:=u;
    FillSpeedsMenu;
  end;
{$ifdef LCLcarbon}
  if TrayIcon.Tag <> 0 then
    TrayIcon.InternalUpdate;
{$endif LCLcarbon}
end;

procedure TMainForm.FillStatistics(s: TJSONObject);

  procedure _Fill(idx: integer; s: TJSONObject);
  begin
    with gStats do begin
      Items[idx, 0]:=UTF8Decode(GetHumanSize(s.Floats['downloadedBytes']));
      Items[idx, 1]:=UTF8Decode(GetHumanSize(s.Floats['uploadedBytes']));
      Items[idx, 2]:=s.Integers['filesAdded'];
      Items[idx, 3]:=UTF8Decode(SecondsToString(s.Integers['secondsActive']));
    end;
  end;

begin
  if RpcObj.RPCVersion < 4 then
    exit;
  if s = nil then begin
    ClearDetailsInfo;
    exit;
  end;
  gStats.BeginUpdate;
  try
    gStats.Enabled:=True;
    gStats.Color:=clWindow;
    _Fill(1, s.Objects['current-stats']);
    _Fill(2, s.Objects['cumulative-stats']);
  finally
    gStats.EndUpdate;
  end;
  DetailsUpdated;
end;

procedure TMainForm.CheckStatus(Fatal: boolean);
var
  s: string;
  i: integer;
begin
  with MainForm do begin
    s:=TranslateString(RpcObj.Status, True);
    if s <> '' then begin
      RpcObj.Status:='';
      if Fatal then
        DoDisconnect;
      ForceAppNormal;
      if Fatal and not RpcObj.Connected and RpcObj.ReconnectAllowed and (FReconnectTimeOut <> -1) then begin
        FReconnectWaitStart:=Now;
        if FReconnectTimeOut < 60 then
          if FReconnectTimeOut < 10 then
            Inc(FReconnectTimeOut, 5)
          else
            Inc(FReconnectTimeOut, 10);
        txConnError.Caption:=s;
        panReconnectFrame.Hide;
        panReconnect.AutoSize:=True;
        CenterReconnectWindow;
        panReconnect.Show;
        panReconnect.BringToFront;
        TickTimerTimer(nil);
        panReconnect.AutoSize:=False;
        panReconnectFrame.Show;
        CenterReconnectWindow;
      end
      else
        MessageDlg(s, mtError, [mbOK], 0);
    end;

    if StatusBar.Panels[0].Text <> RpcObj.InfoStatus then begin
      StatusBar.Panels[0].Text:=RpcObj.InfoStatus;
      TrayIcon.Hint:=RpcObj.InfoStatus;
      if (RpcObj.Connected) and (RpcObj.Http.UserName <> '') then
        FPasswords.Values[FCurConn]:=RpcObj.Http.Password;  // Save password to cache
    end;
    if not RpcObj.Connected then
      for i:=1 to StatusBar.Panels.Count - 1 do
        StatusBar.Panels[i].Text:='';
  end;
end;

function TMainForm.TorrentAction(const TorrentIds: variant; const AAction: string; args: TJSONObject): boolean;
var
  req: TJSONObject;
  ids: TJSONArray;
  i: integer;
begin
  if VarIsEmpty(TorrentIds) then
    exit;
  Application.ProcessMessages;
  AppBusy;
  req:=TJSONObject.Create;
  try
    req.Add('method', AAction);
    if args = nil then
      args:=TJSONObject.Create;
    if not VarIsNull(TorrentIds) then begin
      ids:=TJSONArray.Create;
      if VarIsArray(TorrentIds) then begin
        for i:=VarArrayLowBound(TorrentIds, 1) to VarArrayHighBound(TorrentIds, 1) do
          ids.Add(integer(TorrentIds[i]));
      end
      else
        ids.Add(integer(TorrentIds));
      args.Add('ids', ids);
    end;
    req.Add('arguments', args);
    args:=RpcObj.SendRequest(req, False, 30000);
    Result:=args <> nil;
    args.Free;
  finally
    req.Free;
  end;
  if not Result then
    CheckStatus(False)
  else
    DoRefresh(True);
  AppNormal;
end;

function TMainForm.SetFilePriority(TorrentId: integer; const Files: array of integer; const APriority: string): boolean;

  function CreateFilesArray: TJSONArray;
  var
    i: integer;
  begin
    Result:=TJSONArray.Create;
    for i:=Low(Files) to High(Files) do
      Result.Add(Files[i]);
  end;

var
  req, args: TJSONObject;
begin
  AppBusy;
  req:=TJSONObject.Create;
  try
    req.Add('method', 'torrent-set');
    args:=TJSONObject.Create;
    if TorrentId <> 0 then
      args.Add('ids', TJSONArray.Create([TorrentId]));
    if APriority = 'skip' then
      args.Add('files-unwanted', CreateFilesArray)
    else begin
      args.Add('files-wanted', CreateFilesArray);
      args.Add('priority-' + APriority, CreateFilesArray);
    end;
    req.Add('arguments', args);
    args:=RpcObj.SendRequest(req, False);
    Result:=args<> nil;
    args.Free;
  finally
    req.Free;
  end;
  if not Result then
    CheckStatus(False)
  else
    DoRefresh;
  AppNormal;
end;

function TMainForm.SetCurrentFilePriority(const APriority: string): boolean;
var
  Files: array of integer;
  i, j, k, level: integer;
  pri: string;
begin
  Result:= false;
  if (gTorrents.Items.Count = 0) or (PageInfo.ActivePage <> tabFiles) then exit;
  SetLength(Files, lvFiles.Items.Count);
  pri:=APriority;
  j:=0;
  if APriority <> '' then begin
    // Priority for currently selected rows
    if lvFiles.SelCount = 0 then
      lvFiles.RowSelected[lvFiles.Row]:=True;
    level:=-1;
    for i:=0 to lvFiles.Items.Count - 1 do begin
      k:=FFilesTree.RowLevel[i];
      if k <= level then
        level:=-1;
      if lvFiles.RowSelected[i] or ( (level <> -1) and (k > level) ) then begin
        if FFilesTree.IsFolder(i) then begin
          if level = -1 then
            level:=k;
        end
        else begin
          Files[j]:=FFiles[idxFileId, i];
          Inc(j);
        end;
      end;
    end;
  end
  else begin
    // Priority based on checkbox state
    for i:=0 to FFiles.Count - 1 do
      if not FFilesTree.IsFolder(i) then begin
        k:=FFiles[idxFilePriority, i];
        if (k <> TR_PRI_SKIP) <> (FFilesTree.Checked[i] = cbChecked) then begin
          if pri = '' then
            if FFilesTree.Checked[i] = cbChecked then
              pri:='normal'
            else
              pri:='skip';
          Files[j]:=FFiles[idxFileId, i];
          Inc(j);
        end;
      end;
  end;

  if j = 0 then exit;
  SetLength(Files, j);
  Result:=SetFilePriority(RpcObj.CurTorrentId, Files, pri);
end;

procedure TMainForm.SetTorrentPriority(APriority: integer);
var
  args: TJSONObject;
begin
  if gTorrents.Items.Count = 0 then exit;
  args:=TJSONObject.Create;
  args.Add('bandwidthPriority', TJSONIntegerNumber.Create(APriority));
  TorrentAction(GetSelectedTorrents, 'torrent-set', args);
end;

procedure TMainForm.ProcessPieces(const Pieces: string; PieceCount: integer; const Done: double);
const
  MaxPieces = 4000;
var
  i, j, k, x, xx: integer;
  s: string;
  R: TRect;
  bmp: TBitmap;
  c: double;
begin
  FLastPieces:=Pieces;
  FLastPieceCount:=PieceCount;
  FLastDone:=Done;
  bmp:=nil;
  try
    if FTorrentProgress = nil then
      FTorrentProgress:=TBitmap.Create;
    if RpcObj.RPCVersion >= 5 then begin
      bmp:=TBitmap.Create;
      if PieceCount > MaxPieces then begin
        bmp.Width:=MaxPieces;
        c:=MaxPieces/PieceCount;
      end
      else begin
        bmp.Width:=PieceCount;
        c:=1;
      end;
      bmp.Height:=12;
      bmp.Canvas.Brush.Color:=clWindow;
      bmp.Canvas.FillRect(0, 0, bmp.Width, bmp.Height);
      bmp.Canvas.Brush.Color:=clHighlight;
      x:=0;
      s:=DecodeBase64(Pieces);
      for i:=1 to Length(s) do begin
        j:=byte(s[i]);
        for k:=1 to 8 do begin
          if PieceCount = 0 then
            break;
          if j and $80 <> 0 then begin
            xx:=Trunc(x*c);
            bmp.Canvas.FillRect(xx, 0, xx + 1, bmp.Height);
          end;
          Inc(x);
          j:=j shl 1;
          Dec(PieceCount);
        end;
      end;
    end;

    with FTorrentProgress.Canvas do begin
      FTorrentProgress.Width:=pbDownloaded.ClientWidth;
      if bmp <> nil then begin
        i:=bmp.Height div 3;
        FTorrentProgress.Height:=bmp.Height + 5 + i;
        Brush.Color:=clWindow;
        FillRect(0, 0, FTorrentProgress.Width, FTorrentProgress.Height);
        Brush.Color:=clBtnShadow;
        R:=Rect(0, i + 3, FTorrentProgress.Width, FTorrentProgress.Height);
        FillRect(R);
        InflateRect(R, -1, -1);
        if bmp.Width > 0 then
          StretchDraw(R, bmp)
        else begin
          Brush.Color:=clWindow;
          FillRect(R);
        end;
        R:=Rect(0, 0, FTorrentProgress.Width, i + 2);
      end
      else begin
        FTorrentProgress.Height:=14;
        R:=Rect(0, 0, FTorrentProgress.Width, FTorrentProgress.Height);
      end;
      Brush.Color:=clBtnShadow;
      FillRect(R);
      InflateRect(R, -1, -1);
      x:=R.Left + Round((R.Right - R.Left)*Done/100.0);
      Brush.Color:=clHighlight;
      FillRect(R.Left, R.Top, x, R.Bottom);
      Brush.Color:=clWindow;
      FillRect(x, R.Top, R.Right, R.Bottom);
    end;
    if pbDownloaded.Height <> FTorrentProgress.Height then begin
      pbDownloaded.Constraints.MaxHeight:=FTorrentProgress.Height;
      pbDownloaded.Height:=FTorrentProgress.Height;
      panProgress.AutoSize:=True;
      panProgress.AutoSize:=False;
    end;
    pbDownloaded.Invalidate;
  finally
    bmp.Free;
  end;
end;

function TMainForm.ExecRemoteFile(const FileName: string; SelectFile: boolean; Userdef: boolean): boolean;

  procedure _Exec(s: string);
  var
    p: string;
  begin
    AppBusy;
    if SelectFile then begin
      if FileExistsUTF8(s) then begin
{$ifdef mswindows}
if Userdef then
              begin
                    p:=Format(FUserDefinedMenuParam, [s]);
                    s:=FUserDefinedMenuEx;
              end
              else
              begin
                    p:=Format(FFileManagerDefaultParam, [s]); ; // ALERT  //      p:=Format('/select,"%s"', [s]);
                    s:=FFileManagerDefault;                               //      s:='explorer.exe';
              end;
{$else}
        p:='';
        s:=ExtractFilePath(s);
{$endif mswindows}
      end else begin
        p:='';
        s:=ExtractFilePath(s);
      end;
    end else begin

    end;

{$ifdef mswindows}
if Userdef then
              begin
                    p := Format(FUserDefinedMenuParam, [s]);
                    s := FUserDefinedMenuEx;
              end ;
                    Result:=OpenURL(s, p);
{$else}
      if FLinuxOpenDoc = 0 then
          Result := OpenURL(s, p)    // does not work in latest linux very well!!!! old.vers
      else
          Result := OpenDocument(s); // works better - new.vers
{$endif mswindows}

    AppNormal;
    if not Result then begin
      ForceAppNormal;
      MessageDlg(Format(sUnableToExecute, [s]), mtError, [mbOK], 0);
    end;
  end;

var
  s,r: string;
  i: integer;
begin
  Result:= false;
  s:=MapRemoteToLocal(FileName);
  if s <> '' then begin
    if Userdef then
      begin
      if (lvFiles.Focused) and (lvFiles.SelCount > 1) then
          begin
                r := '';
                for i := 0 to lvFiles.Items.Count-1 do
                  if lvFiles.RowSelected[i] then
                    if r = '' then r := MapRemoteToLocal(FFilesTree.GetFullPath(i)) + '"'  else
                      r := r + ' "'+ MapRemoteToLocal(FFilesTree.GetFullPath(i)) + '"';
                s := r;
          end;
        // else s := '"' + s + '"';
      end;
    _Exec(s);
    exit;
  end;
  if FileExistsUTF8(FileName) or DirectoryExistsUTF8(FileName) then begin
    _Exec(FileName);
    exit;
  end;

  ForceAppNormal;
  MessageDlg(sNoPathMapping, mtInformation, [mbOK], 0);
end;

function TMainForm.GetSelectedTorrents: variant;
var
  i, j: integer;
begin
  with gTorrents do begin
    if Items.Count = 0 then begin
      Result:=Unassigned;
      exit;
    end;
    if SelCount = 0 then
      Result:=VarArrayOf([Items[idxTorrentId, Row]])
    else begin
      Result:=VarArrayCreate([0, SelCount - 1], varinteger);
      j:=0;
      for i:=0 to gTorrents.Items.Count - 1 do
        if gTorrents.RowSelected[i] then begin
          Result[j]:=Items[idxTorrentId, i];
          Inc(j);
        end;
    end;
  end;
end;

function TMainForm.GetDisplayedTorrents: variant;
var
  i,j : integer;
begin
  with gTorrents do begin
    if Items.Count = 0 then begin
      Result:=Unassigned;
      exit;
    end;
        Result:=VarArrayCreate([0, gTorrents.Items.Count - 1], varinteger);
        j:=0;
        for i:=0 to gTorrents.Items.Count - 1 do
          if gTorrents.RowVisible[i] then begin
            Result[j]:=Items[idxTorrentId, i];
            Inc(j);
          end;
  end;
end;

procedure TMainform.StatusBarSizes;
var
  MMap: TMyHashMap;
  ids, cidx: variant;
  TotalSize, TotalDownloaded, TotalSizeToDownload, TorrentDownloaded, TorrentSizeToDownload: Int64;
  i: Integer;
  a, b, c, d: Int64;
begin
    try
    if gTorrents.Items.Count > 0 then
      begin
        if gTorrents.SelCount > 0 then
            ids := GetSelectedTorrents
        else  ids := GetDisplayedTorrents;
        TotalSize := 0;
        TotalDownloaded := 0;
        TotalSizeToDownload := 0;

        MMap := TMyHashMap.Create;
        for i:=0 to FTorrents.Count -1 do
        begin
          MMap[StrToInt(Ftorrents.Items[idxTorrentId, i])] := i;
        end;

        for i:=VarArrayLowBound(ids, 1) to VarArrayHighBound(ids, 1) do
        begin
          cidx := MMap[ids[i]];
          TotalSize             := TotalSize + FTorrents.Items[idxSize, cidx];
          TorrentSizeToDownload := FTorrents.Items[idxSizetoDowload, cidx];
          TorrentDownloaded     := TorrentSizeToDownload * (FTorrents.Items[idxDone, cidx] / 100);
          TotalSizeToDownload   := TotalSizeToDownload + TorrentSizeToDownload;
          TotalDownloaded       := TotalDownloaded + TorrentDownloaded;
        end;
        MMap.Free;

        StatusBar.Panels[4].Text:=Format(sTotalSize,[GetHumanSize(TotalSize, 0, '?')]);
        StatusBar.Panels[5].Text:=Format(sTotalSizeToDownload,[GetHumanSize(TotalSizeToDownload, 0, '?')]);
        StatusBar.Panels[6].Text:=Format(sTotalDownloaded,[GetHumanSize(TotalDownloaded, 0, '?')]);
        StatusBar.Panels[7].Text:=Format(sTotalRemain,[GetHumanSize(TotalSizeToDownload - TotalDownloaded, 0, '?')]);
    end
    else
    begin
      StatusBar.Panels[4].Text:=Format(sTotalSize,[GetHumanSize(0, 0, '?')]);
      StatusBar.Panels[5].Text:=Format(sTotalSizeToDownload,[GetHumanSize(0, 0, '?')]);
      StatusBar.Panels[6].Text:=Format(sTotalDownloaded,[GetHumanSize(0, 0, '?')]);
      StatusBar.Panels[7].Text:=Format(sTotalRemain,[GetHumanSize(0, 0, '?')]);
    end;
    except
        gTorrents.Refresh;
    end;

end;

procedure TMainForm.FillDownloadDirs(CB: TComboBox; const CurFolderParam: string);
var
  i, j, n,xx, m: integer;
  s, IniSec: string;
  lastDt:string;
  pFD : FolderData;

  dd, mm, yy : string;
  nd, nm, ny : integer;
begin
  CB.Items.Clear;

  IniSec   := 'AddTorrent.' + FCurConn;
  j        := Ini.ReadInteger(IniSec, 'FolderCount', 0);

  for i:=0 to j - 1 do begin
    s:=Ini.ReadString(IniSec, Format('Folder%d', [i]), '');
    if s <> '' then begin
      s := CorrectPath (s);

      n := 0;
      for xx:=0 to CB.Items.Count - 1 do begin
        if CB.Items[xx]=s then begin
          n := 1;
        end;
      end;

      if n=0 then begin
        m      := CB.Items.Add(s);
        pFD    := FolderData.create;
        pFD.Hit:= Ini.ReadInteger (IniSec, Format('FolHit%d', [i]), 1);
        pFD.Ext:= Ini.ReadString  (IniSec, Format('FolExt%d', [i]),'');
        lastDt := Ini.ReadString  (IniSec, Format('LastDt%d', [i]),'');
        pFD.Txt:= s; // for debug

        try
      pFD.Lst := EncodeDate(2000,1,1); // last time folder

          if (lastDt <> '') then begin
            dd := Copy (lastDt, 1, 2);
            mm := Copy (lastDt, 4, 2);
            yy := Copy (lastDt, 7, 4);
            nd := StrToInt(dd);
            nm := StrToInt(mm);
            ny := StrToInt(yy);
            if (nd < 1) or (nd > 31)   then nd := 1;
            if (nm < 1) or (nm > 12)   then nm := 1;
            if (ny < 1) or (ny > 2222) then ny := 2000;
            pFD.Lst := EncodeDate(ny,nm,nd);
          end
        except
          MessageDlg('Error: LS-007. Please contact the developer', mtError, [mbOK], 0);
            pFD.Lst := EncodeDate(2000,1,1); // last time folder
        end;

        CB.Items.Objects[m] := pFD;
      end;
    end;
  end;

  s:=CorrectPath (Ini.ReadString(IniSec, CurFolderParam, ''));
  if s <> '' then begin
    i:=CB.Items.IndexOf(s);
    if i > 0 then  // autosorting
      CB.ItemIndex:=i;
    CB.Text := s;
  end
  else begin
    if CB.Items.Count > 0 then
      CB.ItemIndex:=0;
  end;
end;

procedure TMainForm.SaveDownloadDirs(CB: TComboBox; const CurFolderParam: string);
var
  i: integer;
  IniSec: string;
  tmp,selfolder : string;
  strdate : string;
  pFD : FolderData;
begin
  IniSec   := 'AddTorrent.' + FCurConn;
  selfolder:= CorrectPath(CB.Text);
  i        := CB.Items.IndexOf(selfolder);

  try
    if CurFolderParam = 'LastMoveDir' then begin
      if i < 0 then begin
          DeleteDirs (CB, 1);
          CB.Items.Add  (selfolder);
          i := CB.Items.IndexOf(selfolder);
          if i >= 0 then begin
            pFD    := FolderData.create;
            if pFD <> nil then begin
              pFD.Hit:= 1;
              pFD.Ext:= '';
              pFD.Txt:= selfolder;
              pFD.Lst:= IncDay(Today, 7); // +7 days
              CB.Items.Objects[i]:= pFD;
            end;
          end;
      end else begin
          pFD    := CB.Items.Objects[i] as FolderData;
          if pFD <> nil then begin
            pFD.Hit:= pFD.Hit + 1;
            pFD.Lst:= Today;
            CB.Items.Objects[i]:= pFD;
          end;
          DeleteDirs (CB, 0);
      end;
    end;
  except
//    MessageDlg('Error: LS-008. Please contact the developer', mtError, [mbOK], 0);
  end;

  try
    Ini.WriteInteger(IniSec, 'FolderCount', CB.Items.Count);
    for i:=0 to CB.Items.Count - 1 do begin
      tmp := CorrectPath(CB.Items[i]);
      pFD := CB.Items.Objects[i] as FolderData;
      if pFD = nil then continue;

      Ini.WriteString (IniSec, Format('Folder%d', [i]), tmp);
      Ini.WriteInteger(IniSec, Format('FolHit%d', [i]), pFD.Hit);
      Ini.WriteString (IniSec, Format('FolExt%d', [i]), pFD.Ext);

      DateTimeToString(strdate, 'dd.mm.yyyy', pFD.Lst);
      Ini.WriteString (IniSec, Format('LastDt%d', [i]), strdate);
    end;

    // clear string
    Ini.WriteString (IniSec, Format('Folder%d', [i+1]), '' );
    Ini.WriteInteger(IniSec, Format('FolHit%d', [i+1]), -1 );
    Ini.WriteString (IniSec, Format('FolExt%d', [i+1]), '' );
    Ini.WriteString (IniSec, Format('LastDt%d', [i+1]), '' );
  except
    MessageDlg('Error: LS-009. Please contact the developer', mtError, [mbOK], 0);
  end;

  Ini.WriteString(IniSec, CurFolderParam, selfolder); // autosorting, valid from text
  Ini.UpdateFile;
end;

procedure TMainForm.DeleteDirs(CB: TComboBox; maxdel : Integer);
var
  i,min,max,indx, fldr: integer;
  pFD : FolderData;
begin
    max:=Ini.ReadInteger('Interface', 'MaxFoldersHistory',  50);
    Ini.WriteInteger    ('Interface', 'MaxFoldersHistory', max);

    try
    while (CB.Items.Count+maxdel) >= max do begin
      min := 9999999;
      indx:=-1;
      for i:=0 to CB.Items.Count - 1 do begin
        pFD := CB.Items.Objects[i] as FolderData;
        if pFD = nil then continue;

        fldr := DaysBetween(Today,pFD.Lst);
        if Today > pFD.Lst then
          fldr := 0- fldr;

        fldr := fldr + pFD.Hit;
        if fldr < min then begin
          min := fldr;
          indx:= i;
        end;
      end;

      if indx > -1 then
        CB.Items.Delete(indx);
    end;
    except
      MessageDlg('Error: LS-010. Please contact the developer', mtError, [mbOK], 0);
    end;
end;

procedure TMainForm.SetRefreshInterval;
var
  i: TDateTime;
begin
  if Visible and (WindowState <> wsMinimized) then
    i:=Ini.ReadInteger('Interface', 'RefreshInterval', 5)
  else
    i:=Ini.ReadInteger('Interface', 'RefreshIntervalMin', 20);
  if i < 1 then
    i:=1;
  RpcObj.RefreshInterval:=i/SecsPerDay;
end;

procedure TMainForm.AddTracker(EditMode: boolean);
var
  req, args: TJSONObject;
  id, torid: integer;
begin
  AppBusy;
  with TAddTrackerForm.Create(Self) do
  try
    id:=0;
    torid:=RpcObj.CurTorrentId;
    if EditMode then begin
      Caption:=STrackerProps;
      edTracker.Text:=UTF8Encode(widestring(lvTrackers.Items[idxTrackersListName, lvTrackers.Row]));
      id:=lvTrackers.Items[idxTrackerID, lvTrackers.Row];
    end;
    AppNormal;
    if ShowModal = mrOk then begin
      AppBusy;
      Self.Update;
      req:=TJSONObject.Create;
      try
        req.Add('method', 'torrent-set');
        args:=TJSONObject.Create;
        args.Add('ids', TJSONArray.Create([torid]));
        if EditMode then
          args.Add('trackerReplace', TJSONArray.Create([id, UTF8Encode(edTracker.Text)]))  //fix bag
        else
          args.Add('trackerAdd', TJSONArray.Create([UTF8Encode(edTracker.Text)])); //fix bag
        req.Add('arguments', args);
        args:=nil;
        args:=RpcObj.SendRequest(req, False);
        if args = nil then begin
          CheckStatus(False);
          exit;
        end;
        args.Free;
      finally
        req.Free;
      end;
      DoRefresh;
      AppNormal;
    end;
  finally
    Free;
  end;
end;

procedure TMainForm.UpdateConnections;
var
  i, j, cnt: integer;
  s, cur: string;
  mi: TMenuItem;
begin
  while (pmConnections.Items.Count > 0) and (pmConnections.Items[0].Tag = 0) do
    pmConnections.Items[0].Free;
  while (miConnect.Count > 0) and (miConnect.Items[0].Tag = 0) do
    miConnect.Items[0].Free;
  cur:=Ini.ReadString('Hosts', 'CurHost', '');
  cnt:=Ini.ReadInteger('Hosts', 'Count', 0);
  j:=0;
  for i:=1 to cnt do begin
    s:=Ini.ReadString('Hosts', Format('Host%d', [i]), '');
    if s <> '' then begin
      mi:=TMenuItem.Create(pmConnections);
      mi.Caption:=s;
      if s = cur then
        mi.Checked:=True;
      mi.OnClick:=@DoConnectToHost;
      pmConnections.Items.Insert(j, mi);

      mi:=TMenuItem.Create(miConnect);
      mi.Caption:=s;
      if s = cur then
        mi.Checked:=True;
      mi.OnClick:=@DoConnectToHost;
      miConnect.Insert(j, mi);
      Inc(j);
    end;
  end;
  sepCon1.Visible:=j > 0;
  sepCon2.Visible:=j > 0;
end;

procedure TMainForm.DoConnectToHost(Sender: TObject);
var
  mi: TMenuItem;
  Sec: string;
begin
  mi:=TMenuItem(Sender);
  if RpcObj.Connected and (FCurConn = mi.Caption) then
    exit;
  DoDisconnect;
  Sec:='Connection.' + FCurConn;
  if (FReconnectTimeOut = -1) and Ini.ReadBool(Sec, 'Autoreconnect', False) then
        FReconnectTimeOut:=0;
  FCurConn:=mi.Caption;
  DoConnect;
end;

procedure TMainForm.DoSetDownloadSpeed(Sender: TObject);
begin
  SetSpeedLimit('down', TMenuItem(Sender).Tag);
end;

procedure TMainForm.DoSetUploadSpeed(Sender: TObject);
begin
  SetSpeedLimit('up', TMenuItem(Sender).Tag);
end;

procedure TMainForm.SetSpeedLimit(const Dir: string; Speed: integer);
var
  req, args: TJSONObject;
begin
  AppBusy;
  req:=TJSONObject.Create;
  try
    req.Add('method', 'session-set');
    args:=TJSONObject.Create;
    args.Add(Format('speed-limit-%s-enabled', [Dir]), integer(Speed >= 0) and 1);
    if Speed >= 0 then
      args.Add(Format('speed-limit-%s', [Dir]), Speed);
    args.Add('alt-speed-enabled', 0);
    req.Add('arguments', args);
    args:=RpcObj.SendRequest(req, False);
    if args = nil then begin
      CheckStatus(False);
      exit;
    end;
    args.Free;
  finally
    req.Free;
  end;
  RpcObj.RefreshNow:=RpcObj.RefreshNow + [rtSession];
  AppNormal;
end;

function TMainForm.FixSeparators(const p: string): string;
begin
  Result:=StringReplace(p, '/', DirectorySeparator, [rfReplaceAll]);
  Result:=StringReplace(Result, '\', DirectorySeparator, [rfReplaceAll]);
end;

function TMainForm.MapRemoteToLocal(const RemotePath: string): string;
var
  i, j: integer;
  s, ss, fn: string;
begin
  Result:='';
  fn:=FixSeparators(Trim(RemotePath));
  for i:=0 to FPathMap.Count - 1 do begin
    s:=FPathMap[i];
    j:=Pos('=', s);
    if j > 0 then begin
      ss:=FixSeparators(Copy(s, 1, j - 1));
      if (ss = fn) or (Pos(IncludeProperTrailingPathDelimiter(ss), fn) = 1) then begin
        if ss = fn then
          ss:=Copy(s, j + 1, MaxInt)
        else begin
          ss:=IncludeProperTrailingPathDelimiter(ss);
          ss:=IncludeTrailingPathDelimiter(Copy(s, j + 1, MaxInt)) + Copy(fn, Length(ss) + 1, MaxInt);
        end;
        Result:=FixSeparators(ss);
        exit;
      end;
    end;
  end;
end;

function TMainForm.PubMapRemoteToLocal(const RemotePath: string): string;
begin
  Result:=MapRemoteToLocal(RemotePath);
end;

procedure TMainForm.UpdateUIRpcVersion(RpcVersion: integer);
var
  vc: boolean;
begin
  acRemoveTorrentAndData.Visible:=RPCVersion >= 4;
  acReannounceTorrent.Visible:=RPCVersion >= 5;
  acUpdateBlocklist.Visible:=RPCVersion >= 5;
  acMoveTorrent.Visible:=RPCVersion >= 6;
  pmiPriority.Visible:=RPCVersion >= 5;
  miPriority.Visible:=pmiPriority.Visible;
  acOpenContainingFolder.Visible:=RPCVersion >= 4;
  acOpenFile.Visible:=acOpenContainingFolder.Visible;
  pmSepOpen1.Visible:=acOpenContainingFolder.Visible;
  pmSepOpen2.Visible:=acOpenContainingFolder.Visible;
  MenuItem101.Visible:=RPCVersion >= 7;

  vc:=not sepAltSpeed.Visible and (RPCVersion >= 5);
  sepAltSpeed.Visible:=RPCVersion >= 5;
  acAltSpeed.Visible:=RPCVersion >= 5;
  if vc then begin
    sepAltSpeed.Left:=tbStopTorrent.Left + 1;
    tbtAltSpeed.Left:=sepAltSpeed.Left + 1;
  end;

  acAddTracker.Visible:=RPCVersion >= 10;
  acEditTracker.Visible:=acAddTracker.Visible;
  acDelTracker.Visible:=acAddTracker.Visible;
  acAdvEditTrackers.Visible:=acAddTracker.Visible;
  sepTrackers.Visible:=acAddTracker.Visible;

  vc:=not sepQueue.Visible and (RPCVersion >= 14);
  sepQueue.Visible:=RPCVersion >= 14;
  acQMoveUp.Visible:=RPCVersion >= 14;
  acQMoveDown.Visible:=RPCVersion >= 14;
  miQueue.Visible:=RPCVersion >= 14;
  pmiQueue.Visible:=RPCVersion >= 14;
  if vc then begin
    sepQueue.Left:=tbStopTorrent.Left + 1;
    tbQMoveUp.Left:=sepQueue.Left + 1;
    tbQMoveDown.Left:=tbQMoveUp.Left + 1;
  end;
  acForceStartTorrent.Visible:=RPCVersion >= 14;
  tabStats.Visible:=RpcVersion >= 4;
  acRename.Visible:=RpcVersion >= 15;
end;

procedure TMainForm.CheckAddTorrents;
var
  i: integer;
  h: System.THandle;
  s: string;
  WasHidden: boolean;
begin
  h:=FileOpenUTF8(FIPCFileName, fmOpenRead or fmShareDenyWrite);
  if h <> System.THandle(-1) then begin
    i:=FileSeek(h, 0, soFromEnd);
    SetLength(s, i);
    if i > 0 then begin
      FileSeek(h, 0, soFromBeginning);
      SetLength(s, FileRead(h, s[1], i));
    end;
    FileTruncate(h, 0);
    FileClose(h);
    LazFileUtils.DeleteFileUTF8(FIPCFileName);

    if s = '' then begin
      ShowApp;
      exit;
    end;

    FPendingTorrents.Text:=FPendingTorrents.Text + s;
  end;

  if FAddingTorrent <> 0 then
    exit;

  Inc(FAddingTorrent);
  try
    if FPendingTorrents.Count > 0 then begin
      Application.ProcessMessages;
      TickTimer.Enabled:=True;
      WasHidden:=not IsTaskbarButtonVisible;
      if WasHidden then
        Application.BringToFront
      else
        ShowApp;
      try
        while FPendingTorrents.Count > 0 do begin
          s:=FPendingTorrents[0];
          FPendingTorrents.Delete(0);
          if s <> '' then
            DoAddTorrent(s);
        end;
      finally
        if WasHidden then
          HideTaskbarButton;
          FWatchDownloading := false;
      end;
    end;
  finally
    Dec(FAddingTorrent);
  end;
end;

procedure TMainForm.CheckClipboardLink;
const
  strTorrentExt = '.torrent';
var
  s: string;
begin
  try
    if not FLinksFromClipboard then
      exit;
    s:=Clipboard.AsText;
    if s = FLastClipboardLink then
      exit;
    FLastClipboardLink:=s;
    if isHash(s) then s := 'magnet:?xt=urn:btih:' + s;
    if not IsProtocolSupported(s) then
      exit;
    if (Pos('magnet:', LazUTF8.UTF8LowerCase(s)) <> 1) and (LazUTF8.UTF8LowerCase(Copy(s, Length(s) - Length(strTorrentExt) + 1, MaxInt)) <> strTorrentExt) then
      exit;

    AddTorrentFile(s);
    Clipboard.AsText:='';
  except
    // Turn off this function if an error occurs
    FLinksFromClipboard:=False;
  end;
end;

procedure TMainForm.CenterDetailsWait;
begin
  panDetailsWait.Left:=PageInfo.Left + (PageInfo.Width - panDetailsWait.Width) div 2;
  panDetailsWait.Top:=PageInfo.Top + (PageInfo.Height - panDetailsWait.Height) div 2;
end;

function TMainForm.GetPageInfoType(pg: TTabSheet): TAdvInfoType;
begin
  if pg = tabGeneral then
    Result:=aiGeneral
  else
  if pg = tabPeers then
    Result:=aiPeers
  else
  if pg = tabFiles then
    Result:=aiFiles
  else
  if pg = tabTrackers then
    Result:=aiTrackers
  else
  if pg = tabStats then
    Result:=aiStats
  else
    Result:=aiNone;
end;

procedure TMainForm.DetailsUpdated;
begin
  FDetailsWaitStart:=0;
  PageInfo.ActivePage.Tag:=0;
end;

function TMainForm.RenameTorrent(TorrentId: integer; const OldPath, NewName: string): boolean;
var
  args: TJSONObject;
begin
  Result:=False;
  if ExtractFileName(OldPath) = NewName then
    exit;
  args:=TJSONObject.Create;
  args.Add('path', UTF8Decode(OldPath));
  args.Add('name', UTF8Decode(NewName));
  Result:=TorrentAction(TorrentId, 'torrent-rename-path', args);
end;

procedure TMainForm.FilesTreeStateChanged(Sender: TObject);
begin
  SetCurrentFilePriority('');
end;

function TMainForm.SelectTorrent(TorrentId, TimeOut: integer): integer;
var
  tt: TDateTime;
  br: boolean;
begin
  Result:=-1;
  if TorrentId = 0 then
    exit;
  br:=False;
  tt:=Now;
  while True do begin
    Application.ProcessMessages;
    Result:=gTorrents.Items.IndexOf(idxTorrentId, TorrentId);
    if Result >= 0 then begin
      gTorrents.RemoveSelection;
      gTorrents.Row:=Result;
      RpcObj.CurTorrentId:=TorrentId;
      if Self.Visible and (Self.WindowState <> wsMinimized) and gTorrents.Enabled then
        Self.ActiveControl:=gTorrents;
      break;
    end;
    if br then
      break;
    Sleep(100);
    if Now - tt >= TimeOut/MSecsPerDay then
      br:=True;
  end;
end;

procedure TMainForm.OpenCurrentTorrent(OpenFolderOnly: boolean; UserDef: boolean);
var
  res: TJSONObject;
  p, s: string;
  sel: boolean;
  files: TJSONArray;
begin
  if gTorrents.Items.Count = 0 then
    exit;
  Application.ProcessMessages;
  AppBusy;
  try
    sel:=False;
    gTorrents.RemoveSelection;
    res:=RpcObj.RequestInfo(gTorrents.Items[idxTorrentId, gTorrents.Row], ['files', 'downloadDir']);
    if res = nil then
      CheckStatus(False)
    else
      try
        with res.Arrays['torrents'].Objects[0] do begin
          files:=Arrays['files'];
          if files.Count = 0 then exit;
          if files.Count = 1 then begin
            p:=UTF8Encode((files[0] as TJSONObject).Strings['name']);
            sel:=OpenFolderOnly;
          end
          else begin
            //sel:=OpenFolderOnly; // bag? missed?
            s:=GetFilesCommonPath(files);
            repeat
              p:=s;
              s:=ExtractFilePath(p);
            until (s = '') or (s = p);
          end;
          p:=IncludeTrailingPathDelimiter(UTF8Encode(Strings['downloadDir'])) + p;
        end;
      finally
        res.Free;
      end;
    ExecRemoteFile(p, sel, Userdef);
  finally
    AppNormal;
  end;
end;

procedure myDumpAddr(Addr: Pointer;var f:system.text);
begin
  try
    WriteLn(f,BackTraceStrFunc(Addr));
  except
    writeLn(f,SysBackTraceStr(Addr));
  end;
end;
procedure MyDumpExceptionBackTrace(var f:system.text);
var
  FrameCount: integer;
  Frames: PPointer;
  FrameNumber:Integer;
begin
  WriteLn(f,'Stack trace:');
  myDumpAddr(ExceptAddr,f);
  FrameCount:=ExceptFrameCount;
  Frames:=ExceptFrames;
  for FrameNumber := 0 to FrameCount-1 do
    myDumpAddr(Frames[FrameNumber],f);
end;
procedure TMainForm._onException(Sender: TObject; E: Exception);
var
  f:system.text;
  crashreportfilename:shortstring;
begin
    crashreportfilename:='crashreport.txt';
    system.Assign(f,crashreportfilename);
    if FileExists(crashreportfilename) then
        system.Append(f)
    else
        system.Rewrite(f);

    WriteLn(f,'');WriteLn(f,'v.' + AppVersion + ' crashed((');WriteLn(f,'');
    myDumpExceptionBackTrace(f);
    system.close(f);
    halt(0);
end;


procedure TMainForm.FillSpeedsMenu;

  procedure _FillMenu(Items: TMenuItem; const Speeds: string; OnClickHandler: TNotifyEvent; CurSpeed: integer);
  var
    sl: TStringList;
    i, j: integer;
    mi: TMenuItem;
  begin
    Items.Clear;
    if not RpcObj.Connected then
      exit;
    sl:=TStringList.Create;
    try
      sl.Delimiter:=',';
      sl.DelimitedText:=Speeds;
      i:=0;
      while i < sl.Count do begin
        j:=StrToIntDef(Trim(sl[i]), -1);
        if j >= 0 then begin
          sl[i]:=Format('%.08d', [j]);
          Inc(i);
        end
        else
          sl.Delete(i);
      end;
      sl.Duplicates:=dupIgnore;
      sl.Sorted:=True;
      sl.Add(Format('%.08d', [CurSpeed]));

      for i:=0 to sl.Count - 1 do begin
        j:=StrToIntDef(Trim(sl[i]), -1);
        if j >= 0 then begin
          mi:=TMenuItem.Create(Items);
          mi.Caption:=Format('%d %s%s', [j, sKByte, sPerSecond]);
          mi.Tag:=j;
          mi.OnClick:=OnClickHandler;
          if j = CurSpeed then
            mi.Checked:=True;
          Items.Insert(0, mi);
        end;
      end;
    finally
      sl.Free;
    end;
    if Items.Count > 0 then begin
      mi:=TMenuItem.Create(Items);
      mi.Caption:='-';
      Items.Insert(0, mi);
    end;
    mi:=TMenuItem.Create(Items);
    mi.Caption:=SUnlimited;
    mi.Tag:=-1;
    mi.OnClick:=OnClickHandler;
    if CurSpeed = -1 then
      mi.Checked:=True;
    Items.Insert(0, mi);
  end;

var
  s: string;
begin
  s:=Ini.ReadString('Connection.' + FCurConn, 'DownSpeeds', DefSpeeds);
  _FillMenu(pmDownSpeeds.Items, s, @DoSetDownloadSpeed, FCurDownSpeedLimit);
  _FillMenu(pmiDownSpeedLimit, s, @DoSetDownloadSpeed, FCurDownSpeedLimit);

  s:=Ini.ReadString('Connection.' + FCurConn, 'UpSpeeds', DefSpeeds);
  _FillMenu(pmUpSpeeds.Items, s, @DoSetUploadSpeed, FCurUpSpeedLimit);
  _FillMenu(pmiUpSpeedLimit, s, @DoSetUploadSpeed, FCurUpSpeedLimit);
{$ifdef LCLcarbon}
  TrayIcon.InternalUpdate;
{$endif LCLcarbon}
end;

initialization
  {$I main.lrs}

finalization
  try
    FreeAndNil(Ini);
  except
  end;
end.
