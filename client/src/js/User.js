/**
 * Project: Studentske turnaje
 * File: User.js
 * Created: 11.11.2022
 * Author: Jakub Kasem xkasem02@stud.fit.vutbr.cz
 * 
 * Description: Help functions for getting infos about current user
 */

import axios from "axios";
import apiURL from "./apiURL";

const SID = "SID";
const USERNAME = "username";
const USERID = "userID";
const ADMIN = "isAdmin";

export default class User {
    /**
     * @brief Adds PHP session ID to browser session storage
     * 
     * @param _id session ID
     */
    static setSID(_id) {
        sessionStorage.setItem(SID, _id);
    }
    static getSID() {
        return sessionStorage.getItem(SID);
    }
    static setUserID(_id) {
        sessionStorage.setItem(USERID, _id);
    }
    static getUserID() {
        return sessionStorage.getItem(USERID);
    }
    static setUsername(_name) {
        sessionStorage.setItem(USERNAME, _name);
    }
    static getUsername() {
        return sessionStorage.getItem(USERNAME);
    }
    static async setAdminFlag() {
        let _flag = false;
        const getFlag = async () => {
            try {
                const params = new URLSearchParams({ SID: this.getSID() });
                const response = await axios.post(apiURL.users.isAdmin, params);
                _flag = Boolean(response.data);
            } catch (error) {
                console.error(error);
            }
        };
        const setFlag = async () => {
            await getFlag();
            sessionStorage.setItem(ADMIN, _flag);
        }
        await setFlag();
    }
    static isAdmin(){
        return sessionStorage.getItem(ADMIN) === "true";
    }
    static logout(){
        sessionStorage.removeItem(ADMIN);
        sessionStorage.removeItem(USERID);
        sessionStorage.removeItem(USERNAME);
    }
}