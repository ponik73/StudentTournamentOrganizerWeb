/**
 * Project: Studentske turnaje
 * File: InfoClass.js
 * Created: 4.11.2022
 * Author: Jakub Kasem xkasem02@stud.fit.vutbr.cz
 * 
 * Description: Info class with label and content
 */

/**
 * Class is used mainly for Info component to representing data
 */
export default class InfoClass {
    label;
    data;
    constructor(label, data){
        this.label = label;
        this.data = data;
    }
}