class DalkConversation {
    constructor(sdkConversation) {
        this._sdkObject = sdkConversation;
    }

    get id() {
        return this._sdkObject.id;
    }

    get messages() {
        return this._sdkObject.messages;
    }

    get subject() {
        return this._sdkObject.subject;
    }

    get avatar() {
        return this._sdkObject.avatar;
    }

    loadMessages() {
        return dalkLoadMessages(this.id);
    }

    setMessageAsSeen(messageId) {
        return dalkSetMessageAsSeen(this.id, messageId);
    }

    sendMessage(message) {
        return dalkSendMessage(this.id, message);
    }

    setOptions(subject, avatar) {
        return dalkSetOptions(this.id, subject, avatar);
    }
}

class DalkSdk {
    constructor(projectId, me, signature = null) {
        this._sdk = DalkSdkCreate(projectId, me, signature);
    }

    connect() {
        return dalkConnect();
    }

    disconnect() {
        return dalkDisconnect();
    }

    createOneToOneConversation(partner, conversationId = null) {
        return dalkCreateOneToOneConversation(partner, conversationId).then(conversation => {
            return new DalkConversation(conversation);
        });
    }

    createGroupConversation(partners, conversationId = null, subject = null, avatar = null) {
        return dalkCreateGroupConversation(partners, conversationId, subject, avatar).then(conversation => {
            return new DalkConversation(conversation);
        });
    }

    getConversations() {
        return dalkGetConversations().then(conversations => {
            return conversations.map(conversation => new DalkConversation(conversation));
        });
    }

    getConversation(conversationId) {
        return dalkGetConversation(conversationId).then(conversation => {
            return new DalkConversation(conversation);
        });
    }
}
