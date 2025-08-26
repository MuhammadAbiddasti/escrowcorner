@echo off
echo ========================================
echo Daily Git Push Script for EscrowCorner
echo ========================================
echo.

echo Checking Git status...
git status

echo.
echo Adding all changes...
git add .

echo.
echo Committing changes with timestamp...
git commit -m "Daily update: %date% %time%"

echo.
echo Pushing to GitHub...
git push origin main

echo.
echo ========================================
echo Daily push completed!
echo ========================================
pause
