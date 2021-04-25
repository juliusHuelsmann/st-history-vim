void normalMode();
void historyPreDraw();
void historyOverlay(int x, int y, Glyph* g);
void historyModeToggle(int start);
/// Handles keys in normal mode.
typedef enum {failed=0, success=1, exitMotion=2, exitOp=3, finish=4} ExitState;
ExitState kPressHist(char const *txt, size_t len, int ctrl, KeySym const *kSym);
