📱 Flutter Scientific & Basic Calculator
A fully responsive Flutter calculator app built with Riverpod for state management.
Supports portrait (basic calculator) and landscape (scientific calculator) modes, with an additional toggle button to manually switch between them regardless of device orientation.

✨ Features
1. Two Calculator Modes
Basic Mode (Portrait)
Standard operations: addition, subtraction, multiplication, division.
Constants: π, e.
Decimal point support.
Percentage %.
Clear (AC) and Delete (DEL) buttons.
Scientific Mode (Landscape)
Includes all basic features.
Advanced functions: sin, cos, tan, sinh, cosh, tanh, log, ln.
Power and root operations: ^, √, x², x³, xʸ.
Factorial !.
Random number generator (Rand).
Exponentials: 10ˣ, eˣ.
Inverse trig functions: sin⁻¹, cos⁻¹, tan⁻¹.

2. Theme Customization
Change the primary color of the app from the navigation drawer.
Switch between light mode and dark mode.
One-click reset to default theme (Deep Orange, Dark Mode).

3. Manual Mode Switching
"Mode Toggle" button in the AppBar lets you switch between:
Basic Calculator
Scientific Calculator
without rotating your device.

4. Responsive UI
Dynamic button sizing based on available screen size.
Portrait layout: 4-column grid.
Landscape layout: 10-column grid.
Circular buttons with adaptive text scaling.
Display panel adjusts font sizes automatically for readability.

5. Accurate Math Parsing
Uses math_expressions for safe and precise evaluation.
Preprocessing of special symbols before evaluation:
× → *
÷ → /
% → /100
π → math.pi
e → math.e
√ → sqrt()
Factorial n! handled manually.


📂 File Structure
lib/
├── main.dart # Entire app logic and UI
🛠️ Dependencies
flutter_riverpod → State management.
math_expressions → Expression parsing and evaluation.

Add to pubspec.yaml:
yaml

dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.4.0
  math_expressions: ^2.4.0
🚀 How to Run
Clone the repository
git clone https://github.com/mahnoor-zahid0/Flutter-Scientific-Calculator

Navigate into the project
cd flutter-calculator
Get dependencies
flutter pub get
Run the app
flutter run

🎯 Usage Tips
Basic Mode → Short, clean layout for quick calculations.
Scientific Mode → Ideal for advanced math problems.
Swipe from left or tap menu icon to open the drawer for theme changes.
Use DEL for stepwise deletion, AC to reset the expression.