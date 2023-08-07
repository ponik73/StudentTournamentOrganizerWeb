/**
 * Project: Studentske turnaje
 * File: cookies.js
 * Created: 9.11.2022
 * Author: Jakub Kasem xkasem02@stud.fit.vutbr.cz
 * 
 * Description: Cookies functions
 */

export default class Cookies {
    static adminCookieName = 'ADMIN';

    static cookieValue = (name) => (
        document.cookie.match('(^|;)\\s*' + name + '\\s*=\\s*([^;]+)')?.pop() || ''
    )
    static getCookieValue(cookieName) {
        return cookieValue(cookieName);
    }

    static isAdmin() {
        return this.getCookieValue(this.adminCookieName);
    }
}