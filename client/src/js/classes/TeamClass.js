/**
 * Project: Studentske turnaje
 * File: TeamClass.js
 * Created: 6.11.2022
 * Author: Jakub Kasem xkasem02@stud.fit.vutbr.cz
 * 
 * Description: Class for storing Team element
 */

 import InfoClass from "./InfoClass";

export default class TeamClass{
    teamID;
    leaderID;
    leaderName;
    teamName;
    created;
    logoUrl;
    matLost;
    matPlayed;
    matWon;
    tnmntLost;
    tnmntPlayed;
    tnmntWon;
    
    constructor(){

    }

    /**
     * Formats date
     * @param {Not formated date} creationDate 
     * @returns Formated date
     */
    getFormatedDate(creationDate) {
        const options = {
            year: 'numeric',
            month: 'short',
            day: '2-digit',
            hour: '2-digit',
            minute: '2-digit',
        };
        const dateTime = new Intl.DateTimeFormat('en-GB', options).format;
        
        return dateTime(new Date(creationDate));
    }

    /**
     * Gets events win rate
     * @param {Events played} played 
     * @param {Events won} won 
     * @returns Calculated events win rate
     */
    getWinRate(played, won) {
        return parseFloat(won / played * 100).toFixed(2) + "%";
    }

    /**
     * Transform class properties to the info classes
     * @returns List of infos about team
     */
    TransformToInfos() {
        let res = Array();
        res.push(new InfoClass("Team name", this.teamName));
        res.push(new InfoClass("Team leader", this.leaderName));
        res.push(new InfoClass("Created", this.getFormatedDate(this.created)));
        res.push(new InfoClass("Matches played", this.matPlayed));
        if (this.matPlayed > 0)
        {
            res.push(new InfoClass("Matches won", this.matWon));
            res.push(new InfoClass("Matches lost", this.matLost));
            res.push(new InfoClass("Matches win rate", this.getWinRate(this.matPlayed, this.matWon)));
        }

        res.push(new InfoClass("Tournaments played", this.tnmntPlayed));
        if (this.tnmntPlayed > 0)
        {
            res.push(new InfoClass("Tournaments won", this.tnmntWon));
            res.push(new InfoClass("Tournaments lost", this.tnmntLost));
            res.push(new InfoClass("Tournaments win rate", this.getWinRate(this.tnmntPlayed, this.tnmntWon)));
        }

        return res;
    }
}