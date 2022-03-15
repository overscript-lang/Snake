#app Snake, Version="1.0.0"

int PrevDirection, Direction;
Point[] Snake;
Point Target;
int Score;
int IntervalMSec = 500;
double blankCellOpacity = 0.05;
bool GameIsOn = false;
string GameStatus = "";
int FieldWidth = 15, FieldHeight = 15;
object UInt32 = typeof("System.UInt32");
object _0 = 0.As(UInt32);
object _1 = 1.As(UInt32);
object _2 = 2.As(UInt32);
object _3 = 3.As(UInt32);
string AppPath = AppPath();

object StartButton, UpButton, DownButton, LeftButton, RightButton;
object[] CellImage = new object[FieldWidth * FieldHeight];
object StatusLabel;
object GameTimer = Timer(GameTimer_Tick(null, null), IntervalMSec); 
object UpdateGameStateHandler = EventHandler(UpdateGameState());
object UpdateFieldHandler = EventHandler(UpdateField());
object UpdateGameScoreHandler = EventHandler(UpdateGameScore());

object Gtk=LoadAssemblyFrom("GtkSharp.dll");
object Application = GetTypeByName(Gtk, "Gtk.Application");
Application->Init();
object Window = CreateFrom(Gtk, "Gtk.Window", "Snake");

object GdkKey = GetTypeByName("GdkSharp.dll", "Gdk.Key");
int Key_i := GdkKey->i;
int Key_j := GdkKey->j;
int Key_k := GdkKey->k;
int Key_l := GdkKey->l;

ComposeForm();
GameStatus="Welcome!";
UpdateGameState();

Window->ShowAll();
Application->Run();

ComposeForm(){

	object mainTable = CreateFrom(Gtk, "Gtk.Table", _2, _2, false);
	Window->Add(mainTable);
	Window->DeleteEvent += Delegate(Close_Click(null, null), Window->DeleteEvent->EventHandlerType);


	object table=CreateFrom(Gtk, "Gtk.Table", FieldWidth.As(UInt32), FieldHeight.As(UInt32), true);
	table->Margin = 10;

	object imageType=GetTypeByName(Gtk, "Gtk.Image");

	string imagePath=CombinePath(AppPath, "item-25.png");
	int n = 0;
	for (int j = 0; j < FieldHeight; j++)
	{
		for (int i = 0; i < FieldWidth; i++)
		{
			CellImage[n] = Create(imageType);
			CellImage[n]->File = imagePath;
			CellImage[n]->Opacity = blankCellOpacity;
			table->Attach(CellImage[n], i.As(UInt32), (i+1).As(UInt32), j.As(UInt32), (j+1).As(UInt32)); 

			n++;
		}
	}

	CellImage[40]->Opacity = 1;

	mainTable->Attach(table, _0, _2, _0, _1);

	StatusLabel = CreateFrom(Gtk, "Gtk.Label", "Hello!");
	mainTable->Attach(StatusLabel, _0, _1, _1, _2);

	object controlTable = CreateFrom(Gtk, "Gtk.Table", _3, _3, true);
	controlTable->Margin = 10;
	controlTable->RowSpacing = _2;
	controlTable->ColumnSpacing = _2;
	mainTable->Attach(controlTable, _1, _2, _1, _2);

	StartButton = CreateFrom(Gtk, "Gtk.Button", "Start");
	controlTable->Attach(StartButton, _1, _2, _1, _2);

	UpButton = CreateFrom(Gtk, "Gtk.Button", "Up (I)");
	controlTable->Attach(UpButton, _1, _2, _0, _1);

	DownButton = CreateFrom(Gtk, "Gtk.Button", "Down (K)");
	controlTable->Attach(DownButton, _1, _2, _2, _3);

	LeftButton = CreateFrom(Gtk, "Gtk.Button", "Left (J)");
	controlTable->Attach(LeftButton, _0, _1, _1, _2);

	RightButton = CreateFrom(Gtk, "Gtk.Button", "Right (L)");

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

Window_KeyPress(object sender, object args)
{
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
	
	int c = Snake.Slice(0, -1).FindIndex(Point item, item.X == hx && item.Y == hy);
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
			CellImage[n]->Opacity = isBlank ? blankCellOpacity : 1;
			
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

SetTarget() {
	Point point;
	do {
		point = new Point(Rand(0, FieldWidth-1), Rand(0, FieldHeight-1)); 
	} while (Snake.FindIndex(Point item, item.X == point.X && item.Y == point.Y) >= 0);
	Target = point;
}

ResetGame() {
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
	
class Point{
	public int X, Y;
	New(int x, int y){
		X = x;
		Y = y;
	}
}




