/**
 * Project: Studentske turnaje
 * File: PopMessageClass.js
 * Created: 9.11.2022
 * Author: Jakub Kasem xkasem02@stud.fit.vutbr.cz
 * 
 * Description: Class for storing Pop Message properties
 */

 export default class PopMessageClass{
    header;
    body;
    show = false;
    warning = false;

    constructor(){
    }

    toggleShow(){
        this.show = !this.show;
    }
}