/**
 * Project: Studentske turnaje
 * File: PlayerClass.js
 * Created: 9.11.2022
 * Author: Jakub Kasem xkasem02@stud.fit.vutbr.cz
 * 
 * Description: Class for storing Player element
 */

import { plainToInstance } from "class-transformer";
import InfoClass from "./InfoClass";
import TeamClass from "./TeamClass";

export default class PlayerClass {
    userID;
    username;
    created;
    isAdmin;
    isApproved;
    matchesPlayed;
    matWon;
    matLost;
    winRate;
    teams;
    teamList = Array();

    constructor() {
    }

    /**
     * Format date
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
     * Calculate win rate from all events
     * @param {Events played} played 
     * @param {Events won} won 
     * @returns Event's win rate
     */
    getWinRate(played, won) {
        return parseFloat(won / played * 100).toFixed(2) + "%";
    }

    /**
     * Sets team list as Team Classes
     */
    setTeamList(){
        this.teamList = Array();
        this.teams.forEach(element => {
            this.teamList.push(plainToInstance(TeamClass, element));
        });
    }

    /**
     * Transforms user privilege to the string
     * @param {Is user admin as number} currentStatus 
     * @returns String of the user's status
     */
    getStatus(currentStatus) {
        if (currentStatus == '1') return "Admin";

        return "Basic user";
    }

    /**
     * Transform complete PlayerClass to Array of InfoClasses.
     * @return Array(InfoClass)
     */
    TransformToInfos() {
        let res = Array();
        res.push(new InfoClass("Username", this.username));
        res.push(new InfoClass("Privileges", this.getStatus(this.isAdmin)))
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

    TransformToAutocomplete() {
        return { value: this.username, id: this.userID };
    }
}