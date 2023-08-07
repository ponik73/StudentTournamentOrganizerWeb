/**
 * Project: Studentske turnaje
 * File: ErrorMessageConverter.js
 * Created: 22.11.2022
 * Author: Jakub Kasem xkasem02@stud.fit.vutbr.cz
 * 
 * Description: Converting error message from api
 */

 export default class ErrorMessageConverter {
    static convert(mess) {
        const regexp = new RegExp('^ERROR: ');
        if (!regexp.test(mess))
            return "Internal error";
        const _mess = (_m) => {
            return _m.charAt(0).toUpperCase() + _m.slice(1);
        }
        return _mess(mess.substring(7, mess.length));
    }
};