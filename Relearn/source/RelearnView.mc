import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Weather;
using Toybox.Time.Gregorian;

class RelearnView extends WatchUi.WatchFace {

    var customFont = null;
    var mediumNum = null;
    var smallFont = null;
    var hollowFont = null;
    var checkerboard = null;
    var inLowPower = false;
    var canBurnIn = false;
    var shifted = false;
    

    function initialize() {
        WatchFace.initialize();  	
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        customFont = WatchUi.loadResource(Rez.Fonts.type);
        smallFont = WatchUi.loadResource(Rez.Fonts.typeSmall);
        hollowFont = WatchUi.loadResource(Rez.Fonts.hollow);
        checkerboard = WatchUi.loadResource(Rez.Fonts.checkerboard);
        mediumNum = WatchUi.loadResource(Rez.Fonts.mediumNum);
        setLayout(Rez.Layouts.WatchFace(dc));
        canBurnIn = System.getDeviceSettings().requiresBurnInProtection;
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        var bezels = 30;
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        // Call the parent onUpdate function to redraw the layout
        if(!inLowPower){
            View.onUpdate(dc);
        }
        //Write the time
        var timeString = getTimeString();
        if(canBurnIn and inLowPower) {
            dc.setColor(Graphics.COLOR_WHITE,Graphics.COLOR_TRANSPARENT);
            dc.drawText(dc.getWidth()/2, 85, hollowFont, timeString, Graphics.TEXT_JUSTIFY_CENTER);
        }
        else{
            dc.setColor(0xad8944,Graphics.COLOR_TRANSPARENT);
            dc.drawText(dc.getWidth()/2, 85, customFont, timeString, Graphics.TEXT_JUSTIFY_CENTER);
        }

        //If in sleep, write alternating checkerboard over time
        if(canBurnIn and inLowPower) {
            shifted=!shifted;
            dc.setColor(Graphics.COLOR_BLACK,Graphics.COLOR_TRANSPARENT);
            if(shifted){
                dc.drawText(dc.getWidth()/2, 10, checkerboard, "0", Graphics.TEXT_JUSTIFY_CENTER);
            }
            else{
                dc.drawText(dc.getWidth()/2, 9, checkerboard, "0", Graphics.TEXT_JUSTIFY_CENTER);
            }
        }
        
        if(!inLowPower){
            //Write the Date
            var dateString = getDateString();
            dc.setColor(0xad8944, Graphics.COLOR_TRANSPARENT);
            dc.drawText(dc.getWidth()/2, bezels-2, smallFont, dateString, Graphics.TEXT_JUSTIFY_CENTER);
            //Write the temperature
            var tempString = getTempString();
            dc.setColor(0xad8944, Graphics.COLOR_TRANSPARENT);
            dc.drawText(bezels+10, dc.getHeight() - bezels*2-3, mediumNum, tempString, Graphics.TEXT_JUSTIFY_LEFT);
            //Write the Battery
            var batteryString = getBatteryString();
            dc.setColor(0xad8944, Graphics.COLOR_TRANSPARENT);
            dc.drawText(dc.getWidth() - bezels - 8, dc.getHeight() - bezels*2-3, mediumNum, batteryString, Graphics.TEXT_JUSTIFY_RIGHT);
        }
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
        inLowPower = false;
    	WatchUi.requestUpdate(); 
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
        inLowPower = true;
    	WatchUi.requestUpdate();
    }
    
    // Update time values
    private function getTimeString(){
        // Get the current time and format it correctly
        var timeFormat = "$1$:$2$";
        var clockTime = System.getClockTime();
        var hours = clockTime.hour;
        System.println(hours);
        if (hours == 0){
            hours = 12;
        }
        if (!System.getDeviceSettings().is24Hour) {
            if (hours > 12) {
                hours = hours - 12;
                System.println(hours);
            }
        }
        else {
            if (getApp().getProperty("UseMilitaryFormat")) {
                timeFormat = "$1$$2$";
                hours = hours.format("%02d");
            }
        }
        return Lang.format(timeFormat, [hours, clockTime.min.format("%02d")]);
    }
    // Update the battery values
    private function getBatteryString() {
        var charging = System.getSystemStats().charging;
        var start = "";
        if(charging){
            start = "↑";
        }
        return start + System.getSystemStats().battery.format("%d") + "%";
    }

    // Update date
    private function getDateString() {
        var today = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
	    var dateString = Lang.format(
	    "$1$, $2$ $3$",
	    [
	        today.day_of_week,
	        today.month,
	        today.day
	    ] );
        return dateString;
	}

    // Update weather
    private function getTempString() {
        var cast = Weather.getCurrentConditions();
        if(cast!=null) {
            var temp = cast.temperature;
            temp =  temp * 9/5 + 32;
            temp = temp.format("%d");
            return temp+"°";
        }
        else{
            return "-";
        }
	}
}