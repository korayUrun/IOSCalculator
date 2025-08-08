https://github.com/user-attachments/assets/f3a61f93-87b2-463e-8afd-811ee413bb5b

# SwiftCalc

SwiftCalc is a modern calculator app built using UIKit. It includes both a standard and a scientific calculator, with a smooth switch between the two modes.

## Features

- Standard calculator: basic operations (add, subtract, multiply, divide)
- Scientific calculator:  
  - sin, cos, tan (in degrees)  
  - e (Euler’s number)  
  - π (Pi)  
  - 2^x, 10^x, x^x calculations
- Switch button to move between standard and scientific views
- Expression support using infix and postfix conversion for multiple chained operations
- Dynamic expression building: perform multiple-step calculations easily
- Calculation history:
  - Uses `UserDefaults` to save history
  - Displays history using `UITableView`
  - Remains saved between app launches
  - Can be cleared with **Clean History** button

## Technologies Used

- UIKit
- Swift
- UserDefaults
- Auto Layout
- TableView for history
- Gesture Recognizers for UI interactions

## How It Works

- **Switch Button**: Changes between the standard and scientific calculator screens.
- **=**: Evaluates the full expression using infix → postfix → result logic.
- **Clean History**: Clears all saved history from the table view and `UserDefaults`.
- **Dynamic Input**: Add as many numbers and operators as needed — calculations grow as you type.
- **Swipe Gesture**: Used to hide the history panel.

## Notes

- All calculations are done in degrees for trigonometric functions.
- Decimal results are shown as integers if the result is a whole number.
- Supports both portrait and landscape layouts.

## About

This app was created to practice UIKit, expression evaluation (infix/postfix), persistent data storage, and building a clean calculator UI with both basic and scientific capabilities.


