/**
 * Project: Studentske turnaje
 * File: TournamentClass.js
 * Created: 6.11.2022
 * Author: Jakub Kasem xkasem02@stud.fit.vutbr.cz
 * 
 * Description: Class for storing Tournament element
 */

import InfoClass from "./InfoClass";

export default class TournamentClass {
    tnmntID;
    tnmntName;
    gameType;
    participantsCount;
    maxParticipants;
    isForTeams;
    tnmntStart;
    isFinished;
    creatorID;
    creatorName;
    minPlayersPerGame;
    isApproved;
    alreadyStarted;
    participants;

    constructor() {
    }

    /**
     * Format tournament start datetime
     * @returns Formated tournament start
     */
    getStart() {
        const options = {
            year: 'numeric',
            month: 'short',
            day: '2-digit',
            hour: '2-digit',
            minute: '2-digit',
        };
        const dateTime = new Intl.DateTimeFormat('en-GB', options).format;
        
        return dateTime(new Date(this.tnmntStart));
    }

    isTournamentForTeams() {
        return this.isForTeams === '1' ? "Team" : "Solo";
    }

    /**
     * Format tournaments occupancy
     * @returns Tournaments occupancy from max players in tournament
     */
    getOccupancy(){
        return this.participantsCount + " / " + this.maxParticipants;
    }

    isApprovedToStr() {
        return this.isApproved === '1' ? "YES" : "NO";
    }

    getStatus() {
        if(this.isFinished === "1")
        {
            return "Finished";
        }
        else
        {
            if (this.alreadyStarted === "1")
            {
                return "On going"
            }

            return "Not started";
        }
    }

    TransformToInfos() {
        let res = Array();
        res.push(new InfoClass("Title", this.tnmntName));
        res.push(new InfoClass("Game type", this.gameType));
        res.push(new InfoClass("Players", this.getOccupancy()));
        res.push(new InfoClass("Tournament type", this.isTournamentForTeams()));
        if (this.isForTeams === "1")
            res.push(new InfoClass("Minimal players per team", this.minPlayersPerGame));
        res.push(new InfoClass("Expected tournament start", this.getStart()));
        res.push(new InfoClass("Is approved", this.isApprovedToStr()));
        res.push(new InfoClass("Creator", this.creatorName));
        res.push(new InfoClass("Status", this.getStatus()));
        return res;
    }
}