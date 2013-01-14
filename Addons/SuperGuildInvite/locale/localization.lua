﻿SGI_Locale = {}

local function defaultFunc(L,key)
	return key
end

local English = setmetatable({}, {__index=defaultFunc})
	English["English Locale loaded"] = "English Locale loaded"
	English["Enable whispers"] = "Enable whispers"
	English["Level limits"] = nil
	English["Invite Mode"] = nil
	English["Whisper only"] = nil
	English["Invite and whisper"] = nil
	English["Invite only"] = nil
	English["Mute SGI"] = nil
	English["Filter 55-58 Death Knights"] = nil
	English["Do a more thorough search"] = nil
	English["Customize whisper"] = nil
	English["SuperScan"] = nil
	English["Invite: %d"] = nil
	English["Choose Invites"] = nil
	English["Exceptions"] = nil
	English["Help"] = nil
	English["The level you wish to start dividing the search by race"] = nil
	English["Racefilter Start:"] = nil
	English["The level you wish to divide the search by class"] = nil
	English["Classfilter Start:"] = nil
	English["Amount of levels to search every ~7 seconds (higher numbers increase the risk of capping the search results)"] = nil
	English["Interval:"] = nil
	English["SuperGuildInvite Custom Whisper"] = nil
	English["WhisperInstructions"] = "Create a customized whisper to send people you invite! If you enter the words (must be caps) |cff00ff00NAME|r, |cff0000ffLEVEL|r or |cffff0000PLAYER|r these will be replaced by your Guildname, Guildlevel and the recieving players name"
	English["Enter your whisper"] = nil
	English["Save"] = nil
	English["Cancel"] = nil
	English["less than 1 second"] = nil
	English[" hours "] = nil
	English[" minutes "] = nil
	English[" seconds"] = nil
	English[" remaining"] = nil
	English["Purge Queue"] = nil
	English["Click to toggle SuperScan"] = nil
	English["Click on the players you wish to invite"] = nil
	English["Scan Completed"] = nil
	English["Who sent: "] = nil
	English["SuperScan was started"] = nil
	English["SuperScan was stopped"] = nil
	English["PlayersScanned"] = "Players Scanned: |cff44FF44%d|r |cffffff00(Total: |r|cff44FF44%d|r)"
	English["PlayersGuildLess"] = "Guildless Players: |cff44FF44%d|r (|cff44FF44%d%%|r)"
	English["InvitesQueued"] = "Invites Queued: |cff44FF44%d|r"
	English["ExceptionsInstructions"] = "You can add exception phrases that when found in a name will cause the player to be ignore by SuperGuildInvite. You can add several exceptions at once, seperated by a comma (,)."
	English["SGI Exceptions"] = nil
	English["Enter exceptions"] = nil
	English["Go to Options and select your Invite Mode"] = nil
	English["You need to specify the mode in which you wish to invite"] = nil
	English["Unable to invite %s. They are already in a guild."] = nil
	English["Unable to invite %s. They will not be blacklisted."] = nil
	
	--Trouble shooter--
	English["not sending"] = "|cffff8800Why am I not sending any whispers?|r |cff00A2FFPossibly because you have not checked the checkbox.|r|cff00ff00 Click on this message to fix.|r"
	English["to specify"] = "|cffff8800I am getting a message telling me to specify my invite mode when I try to invite!|r|cff00A2FF This happens when you have not used the dropdown menu in the options to pick how to invite people.|r|cff00ff00 Click to fix.|r"
	English["I checked the box"] = "|cffff8800I am not sending any whispers when I invite and I checked the box!|r|cff00A2FF This is because you have selected only to invite with the dropdown menu in the options.|r|cff00ff00 Click to fix|r"
	English["whisper to everyone"] = "|cffff8800I keep sending a whisper to everyone I invite, OR I just want to send whispers and not invite, but your AddOn does both!|r|cff00A2FF This is because you specified to both invite and whisper on the dropdown menu in options.|r|cff00ff00 Click to fix|r"
	English["can't get SGI to invite"] = "|cffff8800I can't get SGI to invite people, all it does is sending whispers.|r|cff00A2FF This is because you picked that option in the dropdown menu.|r|cff00ff00 Click to fix|r"
	English["can't see any messages"] = "|cffff8800I can't see any messages from SGI at all!|r|cff00A2FF This is because you have muted SGI in the options.|r|cff00ff00 Click to fix|r"
	English["None of the above"] = "|cffff8800None of the above solved my problem!|r|cff00A2FF There might be an issue with the localization (language) you are using. You can try to load your locale manually: /sgi locale:deDE loads German (frFR for french). Please contact me at:|r|cff00ff00 SuperGuildInvite@gmail.com|r"
	English["Enabled whispers"] = nil
	English['Changed invite mode to "Invite and Whisper"'] = nil
	English["Mute has been turned off"] = nil
	English['Changed invite mode to "Only Invite". If you wanted "Only Whisper" go to Options and change.'] = nil

	
	English["Shaman"] = nil
	English["Death Knight"] = nil
	English["Mage"] = nil
	English["Priest"] = nil
	English["Rogue"] = nil
	English["Paladin"] = nil
	English["Warlock"] = nil
	English["Druid"] = nil
	English["Warrior"] = nil
	English["Hunter"] = nil
	English["Monk"] = nil
	
	English["Human"] = nil
	English["Gnome"] = nil
	English["Dwarf"] = nil
	English["NightElf"] = nil
	English["Draenei"] = nil
	English["Worgen"] = nil
	English["Pandaren"] = nil
	English["Undead"] = nil
	English["Orc"] = nil
	English["Troll"] = nil
	English["Tauren"] = nil
	English["BloodElf"] = nil
	English["Goblin"] = nil
	
	English["Author"] = "|cff00A2FF Written by Janniie - Stormreaver EU.|r"
	
	--PMG Extra--
	English["Hide minimap button"] = nil
	English["Hide system messages"] = nil
	English["Greet joined players"] = nil
	English["Hide outgoing whisper"] = nil
	English["Set join date in officer note"] = nil
	English["Customize Greet Message"] = nil
	
	
German = setmetatable({}, {__index=defaultFunc})
	German["English Locale loaded"] = "German Locale loaded"
	German["Enable whispers"] = "aktivieren Sie flüstert"
	German["Level limits"] = "Levelbeschränkungen"
	German["Invite Mode"] = "Einladungsart"
	German["Whisper only"] = "Nur anflüstern"
	German["Invite and whisper"] = "Einladen und anflüstern"
	German["Invite only"] = "Nur einladen"
	German["Mute SGI"] = "SGI stummschalten"
	German["Filter 55-58 Death Knights"] = "Level 55-58 Todesritter filtern"
	German["Do a more thorough search"] = "Gründlichere Suche ausführen"
	German["Customize whisper"] = "Flüsternachricht anpassen"
	German["SuperScan"] = "SuperScan"
	German["Invite: %d"] = "Einladen: %d"
	German["Choose Invites"] = "einladungen auswählen"
	German["Exceptions"] = "Ausnahmen"
	German["Help"] = "Hilfe"
	German["SuperGuildInvite Custom Whisper"] = "SuperGuildInvite eigene Flüsternachricht"
	German["WhisperInstructions"] = "Erstelle eine eigene Flüsternachricht, die an die Leute gesendet wird, die du einlädst! Wenn du die worte |cff00ff00NAME|r, |cff0000ffLEVEL|r oder |cffff0000PLAYER|r (in Großbuchstaben) benutzt werden diese durch Gildenname, Gildenlevel und den Namen des Empfängers ersetzt."
	German["Enter your whisper"] = "Flüsternachricht eingeben"
	German["Save"] = "Speichern"
	German["Cancel"] = "Abbrechen"
	German["less than 1 second"] = "weniger als 1 Sekunden verbleibend"
	German[" hours "] = " Stunden "
	German[" minutes "] = " minute "
	German[" seconds"] = " Sekunden"
	German[" remaining"] = " verbleibend"
	German["Purge Queue"] = "Warteschlange leeren"
	German["Click to toggle SuperScan"] = "Klicken um SuperScan zu beenden"
	German["Click on the players you wish to invite"] = "Klicke die Spieler an, die du einladen willst"
	German["Scan Completed"] = "Suchlauf beendet"
	German["Who sent: "] = "Wer-Abfrage gesendet: "
	German["SuperScan was started"] = "SuperScan wurde gestartet"
	German["SuperScan was stopped"] = "SuperScan wurde gestoppt"
	German["PlayersScanned"] = "Spieler durchsucht: |cff44FF44%d|r (Insgesamt: |cff44FF44%d|r)"
	German["PlayersGuildLess"] = "gildenlose Spieler: |cff44FF44%d|r"
	German["InvitesQueued"] = "Einladungen in Warteschlange: |cff44FF44%d|r"
	German["ExceptionsInstructions"] = "Hier kannst du Ausnahmen eingeben, die, wenn sie in einem Namen gefunden werden, dazu führen daß SGI diesen Spieler ignoriert. Du kannst mehrere Ausnahmen durch ein Komma (,) getrennt eingeben."
	German["SGI Exceptions"] = "SGI Ausnahmen"
	German["Go to Options and select your Invite Mode"] = "Gehen Sie auf Optionen und wählen Sie Einladungsart"
	German["You need to specify the mode in which you wish to invite"] = "Sie müssen den Modus, in dem Sie einladen möchten festlegen"
	German["Amount of levels to search every ~7 seconds (higher numbers increase the risk of capping the search results)"] = "Anzahl der Level nach denen etwa alle 7 Sekunden gesucht wird (höhere Zahlen erhöhen das Risiko, daß nicht alle Suchergebnisse bearbeitet werden)."
	German["The level you wish to divide the search by class"] = "Level ab dem nach Klasse gesucht wird."
	German["The level you wish to divide the search by race"] = "Level ab dem nach Rasse gesucht wird."
	
	German["not sending"] = "|cffff8800Warum verschicke ich keine Flüsternachrichten?|r |cff00A2FFMöglicherweise hast du das Kästchen nicht angekreuzt.|r|cff00ff00 Klicke auf diese Nachricht um das Problem zu beheben.|r"
	German["to specify"] = "|cffff8800Ich bekomme eine Nachricht, daß ich die Einladungsart auswählen soll wenn ich jemanden einladen möchte.|r|cff00A2FF Das passiert wenn du nicht das Auswahlmenü in den Optionen benutzt hast um auszuwählen wie du Leute einlädst.|r|cff00ff00 Klicke auf diese Nachricht um das Problem zu beheben.|r"
	German["I checked the box"] = "|cffff8800Ich verschicke keine Flüsternachrichten beim Einladen, obwohl ich das Kästchen angekreuzt habe.|r|cff00A2FF Das passiert wenn du nur einladen im Auswahlmenü ausgewählt hast.|r|cff00ff00 Klicke auf diese Nachricht um das Problem zu beheben.|r"
	German["whisper to everyone"] = "|cffff8800Ich verschicke Flüsternachrichten an jeden den ich einlade ODER ich möchte nur Flüsternachrichten senden aber das AddOn macht beides!|r|cff00A2FF Das passiert weil du einladen und anflüstern im Auswahlmenü ausgewählt hast.|r|cff00ff00 Klicke auf diese Nachricht um das Problem zu beheben.|r"
	German["can't get SGI to invite"] = "|cffff8800SGI lädt keine Leute ein und schickt ausschließlich Flüsternachrichten.|r|cff00A2FF DU hast nur diese Option im Auswahlmenü ausgewählt.|r|cff00ff00 Klicke auf diese Nachricht um das Problem zu beheben.|r"
	German["can't see any messages"] = "|cffff8800Ich sehe keinerlei Ausgabe von SGI.|r|cff00A2FF Du hast SGI in den Optionen stummgeschaltet.|r|cff00ff00 Klicke auf diese Nachricht um das Problem zu beheben.|r"
	German["None of the above"] = "|cffff8800Keine der obenstehenden Lösungen löst mein Problem!|r|cff00A2FF Es könnte ein Problem mit der Lokalisation (Sprache) geben, die du benutzt. Du kannst versuchen mit /sgi locale:deDE die deutschen Sprachoptionen zu laden (frFR für Französisch). Bitte schick mir eine Nachricht an:|r|cff00ff00 SuperGuildInvite@gmail.com|r"
	German["Enabled whispers"] = "Flüsternachrichten eingeschaltet"
	German['Changed invite mode to "Invite and Whisper"'] = "Einladungsart auf einladen und anflüstern geändert"
	German["Mute has been turned off"] = "Stummschaltung wurde ausgeschaltet"
	German['Changed invite mode to "Only Invite". If you wanted "Only Whisper" go to Options and change.'] = "Einladungsmodus auf nur einladen geändert. Wenn du nur anflüstern wolltest, gehe in die Optionen und ändere es dort."
	German["Enter exceptions"] = "Ausnahmen eingeben"
	German["Highest and lowest level to search for"] = "Höchster und niedrigster Level nach dem gesucht wird"
	
	
	German["Shaman"] = "Schamane"
	German["Death Knight"] = "Todesritter"
	German["Mage"] = "Magier"
	German["Priest"] = "Priester"
	German["Rogue"] = "Schurke"
	German["Paladin"] = "Paladin"
	German["Warlock"] = "Hexenmeister"
	German["Druid"] = "Druide"
	German["Warrior"] = "Krieger"
	German["Hunter"] = "Jäger"
	German["Monk"] = "Mönch"
	
	German["Human"] = "Mensch"
	German["Gnome"] = "Gnom"
	German["Dwarf"] = "Zwerg"
	German["NightElf"] = "Nachtelf"
	German["Draenei"] = "Draenei"
	German["Worgen"] = "Worgen"
	German["Pandaren"] = "Pandaren"
	German["Undead"] = "Untoter"
	German["Orc"] = "Ork"
	German["Troll"] = "Troll"
	German["Tauren"] = "Taure"
	German["BloodElf"] = "Blutelf"
	German["Goblin"] = "Goblin"
	
	German["Author"] = "|cff00A2FF Translated by Nephthis - Durotan (EU).|r"

	--PMG Extra--
	German["Hide minimap button"] = nil
	German["Hide system messages"] = nil
	German["Greet joined players"] = nil
	German["Hide outgoing whisper"] = nil
	German["Set join date in officer note"] = nil
	German["Customize Greet Message"] = nil

	
local French = setmetatable({}, {__index=defaultFunc})
	French["English Locale loaded"] = "French Locale loaded"
    French["Enable whispers"] = "Activer les chuchotements"
    French["Level limits"] = "Limites de niveau"
    French["Invite Mode"] = "Mode d'invitation"
    French["Whisper only"] = "Message seulement"
    French["Invite and whisper"] = "Invitation et message"
    French["Invite only"] = "Invitation seulement"
    French["Mute SGI"] = "Mute SGI"
    French["Filter 55-58 Death Knights"] = "Filtrer les Chevaliers de la mort 55-58"
    French["Do a more thorough search"] = "Faire une recherche plus minutieuse"
    French["Customize whisper"] = "Personnaliser le message"
    French["SuperScan"] = "SuperScan"
    French["Invite: %d"] = "Inviter: %d"
    French["Choose Invites"] = "Choisir les invitations"
    French["Exceptions"] = "Exceptions"
    French["Help"] = "Aide"
    French["SuperGuildInvite Custom Whisper"] = "SuperGuildInvite message personnalisé"
    French["WhisperInstructions"] = "Créé un message personnalisé à envoyer aux personne que vous invitez ! Si vous entrez les mots (doivent être en majuscule) |cff00ff00NAME|r, |cff0000ffLEVEL|r ou |cffff0000PLAYER|r ils seront remplacés par le NomDeLaGuilde, NiveauDeLaGuilde et NomDuJoueurInvité."
    French["Enter your whisper"] = "Entrez votre message"
    French["Save"] = "Sauvegarder"
    French["Cancel"] = "Annuler"
    French["less than 1 second"] = "moins d'1 seconde"
    French[" hours "] = " heures "
    French[" minutes "] = " minutes "
    French[" seconds"] = " secondes "
    French[" remaining"] = " restante(s)"
    French["Purge Queue"] = "Vider la liste"
    French["Click to toggle SuperScan"] = "Cliquez pour afficher SuperScan"
    French["Click on the players you wish to invite"] = "Cliquez sur les joueurs que vous souhaitez inviter"
    French["Scan Completed"] = "Scan terminé"
    French["Who sent: "] = "Qui envoyé: "
    French["SuperScan was started"] = "SuperScan démarré"
    French["SuperScan was stopped"] = "SuperScan arrêté"
    French["PlayersScanned"] = "Joueurs scannés: |cff44FF44%d|r |cffffff00(Total: |r|cff44FF44%d|r)"
    French["PlayersGuildLess"] = "Joueurs sans guilde: |cff44FF44%d|r (|cff44FF44%d%%|r)"
    French["InvitesQueued"] = "Invitations listées: |cff44FF44%d|r"
    French["ExceptionsInstructions"] = "Vous pouvez ajouter des exceptions, si le nom d'un joueur correspond à l'une d'elles, SuperGuildInvite l'ignorera. Vous pouvez ajouter plusieurs exceptions à la fois, pour cela séparez les par une virgule (,)."
    French["SGI Exceptions"] = "SGI Exceptions"
    French["Author"] = "|cff00A2FF Translated by Anonymous, you know who you are and thank you :)|r"
    French["Go to Options and select your Invite Mode"] = "Allez dans Options et sélectionnez votre Mode d'invitation."
    French["You need to specify the mode in which you wish to invite"] = "Vous devez spécifier le mode dans lequel vous souhaitez inviter."
    French["not sending"] = "|cffff8800Pourquoi je n'envoie aucun message ?|r |cff00A2FFPeut-être parce que vous n'avez pas coché l'option.|r|cff00ff00 Cliquez sur ce message pour corriger.|r"
    French["to specify"] = "|cffff8800J'ai un message m'indiquant que je dois spécifier le mode d'invitation quand j'essaye d'inviter !|r|cff00A2FF Ceci arrive quand vous n'avez pas utilisé le menu déroulant dans les options pour choisir votre mode d'invitation.|r|cff00ff00 Cliquez pour corriger.|r"
    French["I checked the box"] = "|cffff8800Je n'envoie aucun message lorsque j'invite alors que j'ai coché la case !|r|cff00A2FF C'est parce que vous avez choisi \"Invitation seulement\" comme mode d'invitation.|r|cff00ff00 Cliquez pour corriger.|r"
    French["whisper to everyone"] = "|cffff8800Je continue d'envoyer des invitations, or je veux seulement envoyer un message et ne pas inviter !|r|cff00A2FF C'est parce que vous avez choisi \"Invitation et message\" comme mode d'invitation.|r|cff00ff00 Cliquez pour corriger.|r"
    French["can't get SGI to invite"] = "|cffff8800SGI n'invite personne, il envoie seulement des message.|r|cff00A2FF C'est parce que vous avez choisi \"Message seulement\" comme mode d'invitation.|r|cff00ff00 Cliquez pour corriger.|r"
    French["can't see any messages"] = "|cffff8800Je ne vois plus aucun message de SGI !|r|cff00A2FF C'est parce que vous avez muté SGI dans les options.|r|cff00ff00 Cliquez pour corriger.|r"
    French["None of the above"] = "|cffff8800Aucune des solutions n'a corrigé mon problème !|r|cff00A2FF Il peut y avoir une erreur avec le langage que vous utilisez. Vous pouvez essayer de charger votre langue manuellement : /sgi locale:frFR charge la langue française (deDE pour allemande). Merci de me contacter à :|r|cff00ff00 SuperGuildInvite@gmail.com|r"
    French["Enabled whispers"] = "Cuchotements activés."
    French['Changed invite mode to "Invite and Whisper"'] = 'Mode d\'invitation changé en "Invitation et message".'
    French["Mute has been turned off"] = 'Mute désactivé.'
    French['Changed invite mode to "Only Invite". If you wanted "Only Whisper" go to Options and change.'] = 'Mode d\'invitation changé en "Inviter seulement". Si vous voulez envoyer un "Message seulement" choisissez-le dans les options.'
    French["Enter exceptions"] = 'Entrez les exceptions'

    French["Shaman"] = "Chaman"
    French["Death Knight"] = "Chevalier de la mort"
    French["Mage"] = "Mage"
    French["Priest"] = "Prêtre"
    French["Rogue"] = "Voleur"
    French["Paladin"] = "Paladin"
    French["Warlock"] = "Démoniste"
    French["Druid"] =  "Druide"
    French["Warrior"] = "Guerrier"
    French["Hunter"] = "Chasseur"
    French["Monk"] = "Moine"

    French["Human"] = "Humain"
    French["Gnome"] = "Gnome"
    French["Dwarf"] = "Nain"
    French["NightElf"] = "Elfe de la nuit"
    French["Draenei"] = "Draeneï"
    French["Worgen"] = "Worgen"
    French["Pandaren"] = "Pandaren"
    French["Undead"] = "Mort-vivant"
    French["Orc"] = "Orc"
    French["Troll"] = "Troll"
    French["Tauren"] = "Tauren"
    French["BloodElf"] = "Elfe de sang"
    French["Goblin"] = "Gobelin"

	--PMG Extra--
	French["Hide minimap button"] = nil
	French["Hide system messages"] = nil
	French["Greet joined players"] = nil
	French["Hide outgoing whisper"] = nil
	French["Set join date in officer note"] = nil
	French["Customize Greet Message"] = nil

	
local Spanish = setmetatable({}, {__index=defaultFunc})
	Spanish["English Locale loaded"] = "Spanish Locale loaded"
	Spanish["Enable whispers"] = nil
	Spanish["Level limits"] = nil
	Spanish["Invite Mode"] = nil
	Spanish["Whisper only"] = nil
	Spanish["Invite and whisper"] = nil
	Spanish["Invite only"] = nil
	Spanish["Mute SGI"] = nil
	Spanish["Filter 55-58 Death Knights"] = nil
	Spanish["Do a more thorough search"] = nil
	Spanish["Customize whisper"] = nil
	Spanish["SuperScan"] = nil
	Spanish["Invite: %d"] = nil
	Spanish["Choose Invites"] = nil
	Spanish["Exceptions"] = nil
	Spanish["Help"] = nil
	Spanish["SuperGuildInvite Custom Whisper"] = nil
	Spanish["WhisperInstructions"] = nil
	Spanish["Enter your whisper"] = nil
	Spanish["Save"] = nil
	Spanish["Cancel"] = nil
	Spanish["less than 1 second"] = nil
	Spanish[" hours "] = nil
	Spanish[" minutes "] = nil
	Spanish[" seconds"] = nil
	Spanish[" remaining"] = nil
	Spanish["Purge Queue"] = nil
	Spanish["Click to toggle SuperScan"] = nil
	Spanish["Click on the players you wish to invite"] = nil
	Spanish["Scan Completed"] = nil
	Spanish["Who sent: "] = nil
	Spanish["SuperScan was started"] = nil
	Spanish["SuperScan was stopped"] = nil
	Spanish["PlayersScanned"] = nil
	Spanish["PlayersGuildLess"] = nil
	Spanish["InvitesQueued"] = nil
	Spanish["ExceptionsInstructions"] = nil
	Spanish["SGI Exceptions"] = nil
	Spanish["Author"] = nil
	Spanish["Go to Options and select your Invite Mode"] = nil
	Spanish["You need to specify the mode in which you wish to invite"] = nil
	Spanish["not sending"] = "|cffff8800Why am I not sending any whispers?|r |cff00A2FFPossibly because you have not checked the checkbox.|r|cff00ff00 Click on this message to fix.|r"
	Spanish["to specify"] = "|cffff8800I am getting a message telling me to specify my invite mode when I try to invite!|r|cff00A2FF This happens when you have not used the dropdown menu in the options to pick how to invite people.|r|cff00ff00 Click to fix.|r"
	Spanish["I checked the box"] = "|cffff8800I am not sending any whispers when I invite and I checked the box!|r|cff00A2FF This is because you have selected only to invite with the dropdown menu in the options.|r|cff00ff00 Click to fix|r"
	Spanish["whisper to everyone"] = "|cffff8800I keep sending a whisper to everyone I invite, OR I just want to send whispers and not invite, but your AddOn does both!|r|cff00A2FF This is because you specified to both invite and whisper on the dropdown menu in options.|r|cff00ff00 Click to fix|r"
	Spanish["can't get SGI to invite"] = "|cffff8800I can't get SGI to invite people, all it does is sending whispers.|r|cff00A2FF This is because you picked that option in the dropdown menu.|r|cff00ff00 Click to fix|r"
	Spanish["can't see any messages"] = "|cffff8800I can't see any messages from SGI at all!|r|cff00A2FF This is because you have muted SGI in the options.|r|cff00ff00 Click to fix|r"
	Spanish["None of the above"] = "|cffff8800None of the above solved my problem!|r|cff00A2FF There might be an issue with the localization (language) you are using. You can try to load your locale manually: /sgi locale:deDE loads German (frFR for french). Please contact me at:|r|cff00ff00 SuperGuildInvite@gmail.com|r"
	Spanish["Enabled whispers"] = nil
	Spanish['Changed invite mode to "Invite and Whisper"'] = nil
	Spanish["Mute has been turned off"] = nil
	Spanish['Changed invite mode to "Only Invite". If you wanted "Only Whisper" go to Options and change.'] = nil
	Spanish["Enter exceptions"] = nil
	
	Spanish["Shaman"] = nil
	Spanish["Death Knight"] = nil
	Spanish["Mage"] = nil
	Spanish["Priest"] = nil
	Spanish["Rogue"] = nil
	Spanish["Paladin"] = nil
	Spanish["Warlock"] = nil
	Spanish["Druid"] = nil
	Spanish["Warrior"] = nil
	Spanish["Hunter"] = nil
	Spanish["Monk"] = nil
	
	Spanish["Human"] = nil
	Spanish["Gnome"] = nil
	Spanish["Dwarf"] = nil
	Spanish["NightElf"] = nil
	Spanish["Draenei"] = nil
	Spanish["Worgen"] = nil
	Spanish["Pandaren"] = nil
	Spanish["Undead"] = nil
	Spanish["Orc"] = nil
	Spanish["Troll"] = nil
	Spanish["Tauren"] = nil
	Spanish["BloodElf"] = nil
	Spanish["Goblin"] = nil

	--PMG Extra--
	Spanish["Hide minimap button"] = nil
	Spanish["Hide system messages"] = nil
	Spanish["Greet joined players"] = nil
	Spanish["Hide outgoing whisper"] = nil
	Spanish["Set join date in officer note"] = nil
	Spanish["Customize Greet Message"] = nil

	
local Russian = setmetatable({}, {__index=defaultFunc})
    Russian["English Locale loaded"] = "Russian Locale loaded"
    Russian["Enable whispers"] = "Разрешить сообщения"
    Russian["Level limits"] = "Лимит уровней"
    Russian["Invite Mode"] = "Режим приглашения"
    Russian["Whisper only"] = "Только сообщение"
    Russian["Invite and whisper"] = "Приглашение и сообщение"
    Russian["Invite only"] = "Только приглашение"
    Russian["Mute SGI"] = "Мут SGI"
    Russian["Filter 55-58 Death Knights"] = "Фильтровать Рыцарей Смерти 55-58 уровня"
    Russian["Do a more thorough search"] = "Глубокий поиск"
    Russian["Customize whisper"] = "Настроить Сообщение"
    Russian["SuperScan"] = "СуперСканирование"
    Russian["Invite: %d"] = "Пригласить: %d"
    Russian["Choose Invites"] = "Выбрать Приглашения"
    Russian["Exceptions"] = "Исключения"
    Russian["Help"] = "Помощь"
    Russian["The level you wish to start dividing the search by race"] = "Уровень, с которого включается рассовый фильтр"
    Russian["Racefilter Start:"] = "Рассовый Фильтр"
    Russian["The level you wish to divide the search by class"] = "Уровень, с которого включается классовый фильтр"
    Russian["Classfilter Start:"] = "Классовый Фильтр"
    Russian["Amount of levels to search every ~7 seconds (higher numbers increase the risk of capping the search results)"] = "Интервал уровней для поиска каждые ~7 секунд (больший интервал приводит к риску достигнуть лимита поиска в 49 человек)"
    Russian["Interval:"] = "Интервал"
    Russian["SuperGuildInvite Custom Whisper"] = "сообщение по умолчанию SGI"
    Russian["WhisperInstructions"] = "Create a customized whisper to send people you invite! If you enter the words (must be caps) |cff00ff00NAME|r, |cff0000ffLEVEL|r or |cffff0000PLAYER|r these will be replaced by your Guildname, Guildlevel and the recieving players name"
    Russian["Enter your whisper"] = "Введите свое сообщение"
    Russian["Save"] = "Сохранить"
    Russian["Cancel"] = "Отмена"
    Russian["less than 1 second"] = "Менее 1 секунды"
    Russian[" hours "] = " Часов "
    Russian[" minutes "] = " Минут "
    Russian[" seconds"] = " Секунд "
    Russian[" remaining"] = "осталось"
    Russian["Purge Queue"] = "Очистить Очередь"
    Russian["Click to toggle SuperScan"] = "Нажмите чтобы переключить СуперСкан"
    Russian["Click on the players you wish to invite"] = "Нажмите на игроков которых хотите пригласить"
    Russian["Scan Completed"] = "Сканирование завершено"
    Russian["Who sent: "] = "Кто отправлено: "
    Russian["SuperScan was started"] = "СуперСканирование началось"
    Russian["SuperScan was stopped"] = "Суперсканирование остановлено"
    Russian["PlayersScanned"] = "Players Scanned: |cff44FF44%d|r |cffffff00(Total: |r|cff44FF44%d|r)"
    Russian["PlayersGuildLess"] = "Guildless Players: |cff44FF44%d|r (|cff44FF44%d%%|r)"
    Russian["InvitesQueued"] = "Invites Queued: |cff44FF44%d|r"
    Russian["ExceptionsInstructions"] = "You can add exception phrases that when found in a name will cause the player to be ignore by SuperGuildInvite. You can add several exceptions at once, seperated by a comma (,)."
    Russian["SGI Exceptions"] = "Исключения SGI"
    Russian["Enter exceptions"] = "Ввести исключения"
    Russian["Go to Options and select your Invite Mode"] = "Откройте настройки и выберите режим приглашения"
    Russian["You need to specify the mode in which you wish to invite"] = "Вы должны выбрать режим приглашения"
    Russian["Unable to invite %s. They are already in a guild."] = "Невозможно пришласить %s. Он уже в гильдии"
    Russian["Unable to invite %s. They will not be blacklisted."] = "Невозможно пришласить %s. Он не будет занесен в черный список"
    
    --Trouble shooter--
    Russian["not sending"] = "|cffff8800Why am I not sending any whispers?|r |cff00A2FFPossibly because you have not checked the checkbox.|r|cff00ff00 Click on this message to fix.|r"
    Russian["to specify"] = "|cffff8800I am getting a message telling me to specify my invite mode when I try to invite!|r|cff00A2FF This happens when you have not used the dropdown menu in the options to pick how to invite people.|r|cff00ff00 Click to fix.|r"
    Russian["I checked the box"] = "|cffff8800I am not sending any whispers when I invite and I checked the box!|r|cff00A2FF This is because you have selected only to invite with the dropdown menu in the options.|r|cff00ff00 Click to fix|r"
    Russian["whisper to everyone"] = "|cffff8800I keep sending a whisper to everyone I invite, OR I just want to send whispers and not invite, but your AddOn does both!|r|cff00A2FF This is because you specified to both invite and whisper on the dropdown menu in options.|r|cff00ff00 Click to fix|r"
    Russian["can't get SGI to invite"] = "|cffff8800I can't get SGI to invite people, all it does is sending whispers.|r|cff00A2FF This is because you picked that option in the dropdown menu.|r|cff00ff00 Click to fix|r"
    Russian["can't see any messages"] = "|cffff8800I can't see any messages from SGI at all!|r|cff00A2FF This is because you have muted SGI in the options.|r|cff00ff00 Click to fix|r"
    Russian["None of the above"] = "|cffff8800None of the above solved my problem!|r|cff00A2FF There might be an issue with the localization (language) you are using. You can try to load your locale manually: /sgi locale:deDE loads German (frFR for french). Please contact me at:|r|cff00ff00 SuperGuildInvite@gmail.com|r"
    Russian["Enabled whispers"] = "Разрешить сообщения"
    Russian['Changed invite mode to "Invite and Whisper"'] = "Режим приглашения изменен на 'приглашение и сообщение'"
    Russian["Mute has been turned off"] = "Мут был выключен"
    Russian['Changed invite mode to "Only Invite". If you wanted "Only Whisper" go to Options and change.'] = "Режим приглашения изменен на 'только' пригласить. Если вы хотите приглашать людей, смените режим"
    
    
    
    Russian["Shaman"] = "Шаман"
    Russian["Death Knight"] = "Рыцарь Смерти"
    Russian["Mage"] = "Маг"
    Russian["Priest"] = "Жрец"
    Russian["Rogue"] = "Разбойник"
    Russian["Paladin"] = "Паладин"
    Russian["Warlock"] = "Чернокнижник"
    Russian["Druid"] = "Друид"
    Russian["Warrior"] = "Воин"
    Russian["Hunter"] = "Охотник"
    Russian["Monk"] = "Монах"
    
    Russian["Human"] = "Человек"
    Russian["Gnome"] = "Гном"
    Russian["Dwarf"] = "Дворф"
    Russian["NightElf"] = "Ночной Эльф"
    Russian["Draenei"] = "Дреней"
    Russian["Worgen"] = "Ворген"
    Russian["Pandaren"] = "Пандарен"
    Russian["Undead"] = "Нежить"
    Russian["Orc"] = "Орк"
    Russian["Troll"] = "Тролль"
    Russian["Tauren"] = "Таурен"
    Russian["BloodElf"] = "Эльф Крови"
    Russian["Goblin"] = "Гоблин"
    
    Russian["Author"] = "|cff00A2FF Переведено игроком Вовочкин - Гордунни.|r"
	
	--PMG Extra--
	Russian["Hide minimap button"] = nil
	Russian["Hide system messages"] = nil
	Russian["Greet joined players"] = nil
	Russian["Hide outgoing whisper"] = nil
	Russian["Set join date in officer note"] = nil
	Russian["Customize Greet Message"] = nil

	
SGI_Locale["enGB"] = English
SGI_Locale["enUS"] = English
SGI_Locale["deDE"] = German
SGI_Locale["frFR"] = French
SGI_Locale["ruRU"] = Russian
--SGI_Locale["esES"] = Spanish
--SGI_Locale["esMX"] = Spanish
