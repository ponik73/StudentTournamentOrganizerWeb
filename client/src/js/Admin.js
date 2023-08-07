/**
 * Project: Studentske turnaje
 * File: Admin.js
 * Created: 11.11.2022
 * Author: Jakub Kasem xkasem02@stud.fit.vutbr.cz
 * 
 * Description: Class with functions for admin, this is one of options which was not implemented
 */

import axios from 'axios';
import apiURL from '../js/apiURL';
export default class Admin{
    constructor(){

    }
    static approve(id, type){

    }

    //#region Not implemented functions
    static async  approveTeam(_id){
        try {
            const params = new URLSearchParams({ id: _id});
            const response = await axios.post(apiURL, params); //TODO
        } catch (error) {
            
        }
    }

    static async  approvePlayer(_id){
        try {
            const params = new URLSearchParams({ id: _id});
            const response = await axios.post(apiURL, params); //TODO
        } catch (error) {
            
        }
    }

    static async  approveTournament(_id){
        try {
            const params = new URLSearchParams({ id: _id});
            const response = await axios.post(apiURL, params); //TODO
        } catch (error) {
            
        }
    }

    static async  disapproveTeam(_id){
        try {
            const params = new URLSearchParams({ id: _id});
            const response = await axios.post(apiURL, params); //TODO
        } catch (error) {
            
        }
    }

    static async  disapprovePlayer(_id){
        try {
            const params = new URLSearchParams({ id: _id});
            const response = await axios.post(apiURL, params); //TODO
        } catch (error) {
            
        }
    }

    static async  disapproveTournament(_id){
        try {
            const params = new URLSearchParams({ id: _id});
            const response = await axios.post(apiURL, params); //TODO
        } catch (error) {
            
        }
    }
    //#endregion
}