#app Snake, Version="2.0.0"

int PrevDirection, Direction;
Point[] Snake;
Point Target;
int Score;
const int IntervalMSec = 500;
const double BlankCellOpacity = 0.05, CellOpaque = 1.0;
bool GameIsOn = false;
string GameStatus = "";
const int FieldWidth = 15, FieldHeight = 15;
const object UInt32 = typeof("System.UInt32");
const object _0 = `UInt32\0;
const object _1 = `UInt32\1;
const object _2 = `UInt32\2;
const object _3 = `UInt32\3;

const object Gtk = LoadAssemblyFrom("GtkSharp.dll");
const object GtkImage = GetTypeByName(Gtk, "Gtk.Image");
const object GtkButton = GetTypeByName(Gtk, "Gtk.Button");
const object GtkLabel = GetTypeByName(Gtk, "Gtk.Label");

`GtkButton StartButton, UpButton, DownButton, LeftButton, RightButton;
`GtkImage[] CellImage = new `GtkImage[FieldWidth * FieldHeight];
`GtkLabel StatusLabel;
object GameTimer = Timer(GameTimer_Tick(null, null), IntervalMSec); 
object UpdateGameStateHandler = EventHandler(UpdateGameState());
object UpdateFieldHandler = EventHandler(UpdateField());
object UpdateGameScoreHandler = EventHandler(UpdateGameScore());

const object Application = GetTypeByName(Gtk, "Gtk.Application");
Application->Init();

const object GtkWindow = GetTypeByName(Gtk, "Gtk.Window");
`GtkWindow Window = GtkWindow.Create("Snake");

const object GdkKey = typeof("GdkSharp.dll", "Gdk.Key");
int Key_i := GdkKey->i;
int Key_j := GdkKey->j;
int Key_k := GdkKey->k;
int Key_l := GdkKey->l;

ComposeForm();
GameStatus = "Welcome!";
UpdateGameState();

Window->ShowAll();
Application->Run();

ComposeForm(){
	const object GtkTable = GetTypeByName(Gtk, "Gtk.Table");
	`GtkTable mainTable = GtkTable.Create(_2, _2, false);
	Window->Add(mainTable);
	Window->DeleteEvent += Delegate(Close_Click(null, null), Window->DeleteEvent->EventHandlerType);

	`GtkTable table = GtkTable.Create(`UInt32\FieldWidth, `UInt32\FieldHeight, true);
	table->Margin = 10;

	string imagePath=CombinePath(AppPath(), "item-25.png");
	int n = 0;
	for (int j = 0; j < FieldHeight; j++)
	{
		for (int i = 0; i < FieldWidth; i++)
		{
			CellImage[n] = GtkImage.Create();
			CellImage[n]->File = imagePath;
			CellImage[n]->Opacity = BlankCellOpacity;
			table->Attach(CellImage[n], `UInt32\i, `UInt32\(i+1), `UInt32\j, `UInt32\(j+1)); 

			n++;
		}
	}

	CellImage[40]->Opacity = CellOpaque;

	mainTable->Attach(table, _0, _2, _0, _1);

	StatusLabel = GtkLabel.Create("Hello!");
	mainTable->Attach(StatusLabel, _0, _1, _1, _2);
	
	`GtkTable controlTable = GtkTable.Create(_3, _3, true);
	controlTable->Margin = 10;
	controlTable->RowSpacing = _2;
	controlTable->ColumnSpacing = _2;
	mainTable->Attach(controlTable, _1, _2, _1, _2);

	
	StartButton = GtkButton.Create("Start");
	controlTable->Attach(StartButton, _1, _2, _1, _2);

	UpButton = GtkButton.Create("Up (I)");
	controlTable->Attach(UpButton, _1, _2, _0, _1);

	DownButton = GtkButton.Create("Down (K)");
	controlTable->Attach(DownButton, _1, _2, _2, _3);

	LeftButton = GtkButton.Create("Left (J)");
	controlTable->Attach(LeftButton, _0, _1, _1, _2);

	RightButton = GtkButton.Create("Right (L)");

	controlTable->Attach(RightButton, _2, _3, _1, _2);
	
	StartButton->Clicked += EventHandler(Start_Click(null, null));
	UpButton->Clicked += EventHandler(Up_Click(null, null));
	DownButton->Clicked += EventHandler(Down_Click(null, null));
	LeftButton->Clicked += EventHandler(Left_Click(null, null));
	RightButton->Clicked += EventHandler(Right_Click(null, null));
	
	Window->KeyPressEvent += Delegate(Window_KeyPress(null, null), Window->KeyPressEvent->EventHandlerType);
	
}


StartGame(){
	ResetGame();
	GameIsOn = true;
	GameStatus = "Started";
	GtkApplicationInvoke(UpdateGameStateHandler);
	GameTimer.StartTimer();
	
}

StopGame(bool byUser = false){
	GameTimer.StopTimer();

	GameIsOn = false;
	GameStatus = byUser ? "Stopped" : "GAME OVER\nScore: "+Score;
	
	GtkApplicationInvoke(UpdateGameStateHandler);

}

GtkApplicationInvoke(object handler){
	Application->Invoke(handler);
}

UpdateGameState(){
	StatusLabel->Text = GameStatus;
	StartButton->Label = GameIsOn ? "Stop" : "Start";
	UpButton->Sensitive = GameIsOn;
	DownButton->Sensitive = GameIsOn;
	LeftButton->Sensitive = GameIsOn;
	RightButton->Sensitive = GameIsOn;
}

Up_Click(object sender, object args){
	SetDirection(0);
}

Down_Click(object sender, object args){
	SetDirection(2);	
}

Left_Click(object sender, object args){
	SetDirection(3);
}

Right_Click(object sender, object args){
	SetDirection(1);
}

Start_Click(object sender, object args){
	if(GameIsOn) StopGame(true);
	else StartGame();

}

Window_KeyPress(object sender, object args){
	int key := args->Event->Key;

	if(key == Key_i) Up_Click(sender, args);
	else if(key == Key_j) Left_Click(sender, args);
	else if(key == Key_k) Down_Click(sender, args);
	else if(key == Key_l) Right_Click(sender, args);
	
}
		
Close_Click(object sender, object args){
	Application->Quit();
}

GameTimer_Tick(object source, object e){
	int d = Direction;
	if (Abs(PrevDirection - d) == 2){ 
		PrevDirection = d;
		Snake.Reverse(); 

		return;
	}

	PrevDirection = d;
	
	int hx = Snake[0].X;
	int hy = Snake[0].Y;
	
	switch (d) {
		case 0:
			hy--;
			break;
		case 1:
			hx++;
			break;
		case 2:
			hy++;
			break;
		case 3:
			hx--;
			break;

	}
	
	int c = Snake[0..-1].FindIndex(Point item, item.X == hx && item.Y == hy);
	bool outOfField = hx < 0 || hx >= FieldWidth || hy < 0 || hy >= FieldHeight;
	
	if (outOfField || c >=0) {
		StopGame();
		
		return;
	}
	
	int lastIndex = Snake.Length() - 1;
	Point lastCell = Snake[lastIndex];
	for (int i = lastIndex; i > 0; i--) Snake[i] = Snake[i - 1];
	Snake[0] = new Point(hx, hy);

	if (Snake[0].X == Target.X && Snake[0].Y == Target.Y) {
		Score++;
		Snake.Push(lastCell);
		SetTarget();
		GtkApplicationInvoke(UpdateGameScoreHandler);
	}

	GtkApplicationInvoke(UpdateFieldHandler);

}

UpdateGameScore() {
	StatusLabel->Text = "Score: "+Score;
}
	
UpdateField(){
	int n = 0;
	for (int j = 0; j < FieldHeight; j++)
	{
		for (int i = 0; i < FieldWidth; i++)
		{
			bool isBlank = Snake.FindIndex(Point item, item.X == i && item.Y == j)<0 && !(Target.X == i && Target.Y == j);
			CellImage[n]->Opacity = isBlank ? BlankCellOpacity : CellOpaque;
			
			n++;
		}
	}

}

SetDirection(int d){
	Direction = d;
}

SetTarget(int x, int y){
	Target = new Point(x, y); 
}

SetTarget(){
	Point point;
	do {
		point = new Point(Rand(0, FieldWidth-1), Rand(0, FieldHeight-1)); 
	} while (Snake.FindIndex(Point item, item.X == point.X && item.Y == point.Y) >= 0);
	Target = point;
}

ResetGame(){
	int sx = FieldWidth / 2;
	int sy = FieldHeight / 2;
	int snakeLen = 3;
	Snake = new Point[snakeLen];
	for (int q = 0; q < snakeLen; q++) Snake[q] = new Point(sx, sy + q);

	PrevDirection = Direction = 0;
	Score = 0;
	SetTarget();
	GtkApplicationInvoke(UpdateFieldHandler);

}
	
class Point
{
	public int X, Y;
	New(int x, int y){
		X = x;
		Y = y;
	}
}

