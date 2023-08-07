/**
 * Project: Studentske turnaje
 * File: MatchClass.js
 * Created: 22.11.2022
 * Author: Adam Dzurilla xdzuri00@stud.fit.vutbr.cz
 * 
 * Description: Class for storing Match element
 */

import InfoClass from "./InfoClass";

export default class MatchClass {
    matchID;
    matchStart;
    partOneID;
    partOneOGID;    // User or team id of the participant
    partOneName;
    partOneScore;
    partTwoID;
    partTwoOGID;    // User or team id of the participant
    partTwoName;
    partTwoScore;
    tnmntRound;
    isFinished;
    tnmntID;
    isUserMatch;

    constructor() 
    {
    }

    /**
     * Format given date
     * @param {Not formated date} date 
     * @returns Formated date
     */
    getFormatedDate(date) 
    {
        const options = {
            year: 'numeric',
            month: 'short',
            day: '2-digit',
            hour: '2-digit',
            minute: '2-digit',
        };
        const dateTime = new Intl.DateTimeFormat('en-GB', options).format;
        
        return dateTime(new Date(date));
    }

    /**
     * Transform round from string int to the string round title
     * @param {Round as int} round 
     * @returns Formated round to the string
     */
    getRoundAsString(round)
    {
        // Transforms round to the string
        switch (round) {
            case '1':
                return 'Final';
            case '2':
                return 'Semifinal';
            case '4':
                return 'Quaterfinal';
            case '8':
                return 'Eighth-final';
        }

        return round + 'th-final';
    }

    getIsFinished(isFinishedFlag)
    {
        return isFinishedFlag === "1" ? "Finished" : "Not finished";
    }

    /**
     * Transform complete class to Array of InfoClasses.
     * @return Array(InfoClass)
     */
    transformToInfos() {
        let res = Array();
        if (this.isFinished === "1")
        {
            res.push(new InfoClass("Match start", this.getFormatedDate(this.matchStart)));
        }
        else
        {
            res.push(new InfoClass("Expected match start", this.getFormatedDate(this.matchStart)));
        }
        res.push(new InfoClass("Round", this.getRoundAsString(this.tnmntRound)));
        res.push(new InfoClass("Match status", this.getIsFinished(this.isFinished)));

        return res;
    }
}