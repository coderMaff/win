/*****************************************************************************
**                                                                          **
**               WIN v2.1 (c)1996 Matthew Bushell aka Maffia / NVX          **
**                 Coded in Amiga-E v3.1i - Using GoldED PRO                **
**                                                                          **
*****************************************************************************/

->FOLD ENUMS
ENUM    NONE,
        ER_OPENLIB,
        ER_SCREEN,
        ER_VISUAL,
        ER_CONTEXT,
        ER_GADGET,
        ER_WINDOW,
        ER_FILE,
        ER_ALLOC,
        ER_TEXT,
        ER_WB,
        ER_MENUS,  -> Error Creating/Using Menus <-
        ER_PREFS   -> Couldnt Write prefs file.
->FEND
->FOLD CONSTS
/********************************[ Const ]***********************************/

CONST   ZERO=0
->FEND
->FOLD MODULES
/********************************[ Modules ]*********************************/

MODULE  'intuition/intuition',
        'intuition/screens',
        'intuition/gadgetclass',
        'gadtools',
        'reqtools',
        'libraries/reqtools',
        'libraries/gadtools',
        'exec/nodes',
        'tools/file',
        'dos/dos',
        'exec/memory',
        'exec/nodes',
        'exec/lists',
        'graphics/text'
->        'oomodules/datetime' /* Lost this with HD crash! <-
->FEND
->FOLD GLOBAL DEFS
/********************************[ Global DEFS ]*****************************/

DEF wnd:PTR TO window,
    glist,
    scr:PTR TO screen,
    visual = 0,
    g:PTR TO gadget,
    topaz:PTR TO textattr,
    infos=0,
    mes:PTR TO intuimessage,
    offy,
    type,
    key=FALSE,
    gadtool=FALSE,
    req:PTR TO rtfilerequester,
    buf[120]:STRING,                ->Buffer for Reqtools requester
    menu,

    list=NIL:PTR TO mlh,
    lv=NIL:PTR TO gadget,
    buffer[20]:STRING,

    p_lib=NIL:PTR TO gadget,
    p_dev=NIL:PTR TO gadget,
    p_fon=NIL:PTR TO gadget,
    g_l=NIL:PTR TO gadget,
    g_q=NIL:PTR TO gadget,
    g_c=NIL:PTR TO gadget,
    g_h=NIL:PTR TO gadget,
    g_a=NIL:PTR TO gadget,
    g_o=NIL:PTR TO gadget,

    libs=TRUE,
    devs=TRUE,
    font=TRUE,

    opt=FALSE,  -> Is the options window open?

    out=TRUE,
    wor=TRUE,

    debugmode=FALSE,

    icon=FALSE,
    fied=FALSE
->FEND

->FOLD PROC MAIN
/*******************************[ PROC Main ]********************************/

PROC main() HANDLE

DEF done=FALSE

    IF StrCmp(arg,'-D') THEN debugmode:=TRUE
    loadprefs()
    setup()
    REPEAT
        wait4message(wnd)
        IF ((infos=$0) OR (infos=$FFFFF900)) AND (opt=FALSE)
            done:=TRUE
        ELSEIF ((infos=$2) OR (infos=$FFFFF8C0))
            doabout()
        ELSEIF ((infos=$3) OR ((infos=$FFFFF801) AND (opt=FALSE) AND (icon=FALSE)))
            SetWindowTitles(wnd,'W.I.N v2.oo    Options Mode, Please Select:   ',
                                'Whats It Need v2.oo  (c)1996 Matthew Bushell')
            opt:=TRUE
            killgadgets(TRUE,0,0,0,1,1,0,1,1,0)
            MoveWindow(wnd,-150,0)
            SizeWindow(wnd,150,0)
        ELSEIF (infos=$4)
            IF libs=TRUE
                libs:=FALSE
            ELSE
                libs:=TRUE
            ENDIF
        ELSEIF (infos=$5)
            IF devs=TRUE
                devs:=FALSE
            ELSE
                devs:=TRUE
            ENDIF
        ELSEIF (infos=$6)
            IF font=TRUE
                font:=FALSE
            ELSE
                font:=TRUE
            ENDIF
        ELSEIF ((infos=$8) OR (infos=$FFFFF802) AND (opt=FALSE) AND (icon=FALSE))
            ZipWindow(wnd)
->            icon:=TRUE
->            SizeWindow(wnd,-100,-106)
        ELSEIF ((infos=$FFFFF822) AND (icon=TRUE))
            icon:=FALSE
            MoveWindow(wnd,-100,-106)
            SizeWindow(wnd,100,106)
            Delay(3)
            DrawBevelBoxA(wnd.rport,235,3,195,100,[GT_VISUALINFO,visual,
                                           GTBB_RECESSED,TRUE,
                                           GTBB_FRAMETYPE,BBFT_RIDGE,0])
        ELSEIF ((infos=$9) OR (infos=$FFFFF8E0))
            RtEZRequestA({help},'_Right!',0,0,[RT_UNDERSCORE,"_",
                                               RT_TEXTATTR,topaz,
                                               RT_WINDOW,wnd,
                                               RTEZ_REQTITLE,' WIN2 Help Page.'])
        ELSEIF (infos=$A)
            IF out=TRUE
                out:=FALSE
            ELSE
                out:=TRUE
            ENDIF
        ELSEIF (infos=$B)
            IF wor=TRUE
                wor:=FALSE
            ELSE
                wor:=TRUE
            ENDIF
        ELSEIF (infos=$C)
            IF fied=TRUE
                fied:=FALSE
            ELSE
                fied:=TRUE
            ENDIF
        ELSEIF (((infos=$D) OR (infos=$FFFFF801)) AND (icon=FALSE))
            opt:=FALSE
            SizeWindow(wnd,-150,0)
            killgadgets(FALSE,1,1,1,1,1,1,1,1,1)
            SetWindowTitles(wnd,'W.I.N v2.oo    Finished Options. Ready!',
                                'Whats It Need v2.oo  (c)1996 Matthew Bushell')
        ELSEIF (infos=$E) OR (infos=$FFFFF821)
            SetWindowTitles(wnd,'W.I.N v2.oo    Saving Prefs...',
                                'Whats It Need v2.oo  (c)1996 Matthew Bushell')
            saveprefs()
            SetWindowTitles(wnd,'W.I.N v2.oo    Prefs Saved. Ready!',
                                'Whats It Need v2.oo  (c)1996 Matthew Bushell')
        ELSEIF ((infos=$FFFFF800) OR (infos=1)) AND (opt=FALSE)
            dofile(libs,devs,font)
        ELSEIF (infos=$FFFFF820)
            libs:=TRUE
            devs:=TRUE
            font:=TRUE
            Gt_SetGadgetAttrsA(p_lib,wnd,NIL,[GTCB_CHECKED,libs,
                                              NIL])
            Gt_SetGadgetAttrsA(p_dev,wnd,NIL,[GTCB_CHECKED,devs,
                                              NIL])
            Gt_SetGadgetAttrsA(p_fon,wnd,NIL,[GTCB_CHECKED,font,
                                              NIL])
        ELSEIF (infos=$FFFFF840)
            IF libs=TRUE
                libs:=FALSE
            ELSE
                libs:=TRUE
            ENDIF
            Gt_SetGadgetAttrsA(p_lib,wnd,NIL,[GTCB_CHECKED,libs,
                                              NIL])
        ELSEIF (infos=$FFFFF860)
            IF devs=TRUE
                devs:=FALSE
            ELSE
                devs:=TRUE
            ENDIF
            Gt_SetGadgetAttrsA(p_dev,wnd,NIL,[GTCB_CHECKED,devs,
                                              NIL])
        ELSEIF (infos=$FFFFF880)
            IF font=TRUE
                font:=FALSE
            ELSE
                font:=TRUE
            ENDIF
            Gt_SetGadgetAttrsA(p_fon,wnd,NIL,[GTCB_CHECKED,font,
                                              NIL])
        ELSEIF (infos=$FFFFF8A0)
            libs:=FALSE
            devs:=FALSE
            font:=FALSE
            Gt_SetGadgetAttrsA(p_lib,wnd,NIL,[GTCB_CHECKED,libs,
                                              NIL])
            Gt_SetGadgetAttrsA(p_dev,wnd,NIL,[GTCB_CHECKED,devs,
                                              NIL])
            Gt_SetGadgetAttrsA(p_fon,wnd,NIL,[GTCB_CHECKED,font,
                                              NIL])
        ENDIF
        IF debugmode THEN WriteF('Infos:\h\n',infos)
        infos:=0
    UNTIL done
    Raise(NONE)
EXCEPT
    closedown()
    IF exception>0 THEN WriteF('Error #\s \n',
    ListItem(['00 0:No Error!',
              '001:Opening Needed Library - ReqTools',
              '002:Screen',
              '003:Visual',
              '004:Context',
              '005:Gadget',
              '006:Window',
              '007:File',
              '008:Alloc',
              '009:Allocating Memory',
              '010:Font',
              '011:Workbench',
              '012:Menus',
              '013:Saving Prefs File'],exception))
ENDPROC
->FEND
->FOLD PROC SETUP
/*******************************[ PROC Setup ]*******************************/

PROC setup()
    list:=New(SIZEOF mlh)
    initlist(list)
    IF (topaz:=['topaz.font',8,0,FPF_ROMFONT]:textattr)=NIL THEN Raise(ER_TEXT)
    IF (gadtoolsbase:=OpenLibrary('gadtools.library',37))=NIL THEN Raise(ER_OPENLIB)
    IF (reqtoolsbase:=OpenLibrary('reqtools.library',37))=NIL THEN Raise(ER_OPENLIB)
    IF (req:=RtAllocRequestA(req,0))=NIL THEN Raise(ER_ALLOC)
    IF (scr:=LockPubScreen('Workbench'))=NIL THEN Raise(ER_WB)
    IF (visual:=GetVisualInfoA(scr,NIL))=NIL THEN Raise(ER_VISUAL)
    offy:=scr.wbortop+Int(scr.rastport+58)-10
    IF (g:=CreateContext({glist}))=NIL THEN Raise(ER_CONTEXT)
    IF (menu:=CreateMenusA([NM_TITLE,0,'Project',0,$0,0,0,
        NM_ITEM,0,'Get and Check File  ','g',0,0,0,
        NM_ITEM,0,'All checks on       ','a',0,0,0,
        NM_ITEM,0,'Libs check on/off   ','l',0,0,0,
        NM_ITEM,0,'Devs check on/off   ','d',0,0,0,
        NM_ITEM,0,'Fonts check on/off  ','f',0,0,0,
        NM_ITEM,0,'All checks off      ','n',0,0,0,
        NM_ITEM,0,'About               ','?',0,0,0,
        NM_ITEM,0,'Help                ','h',0,0,0,
        NM_ITEM,0,'Quit                ','Q',0,0,0,
        NM_TITLE,0,'Options',0,$0,0,0,
        NM_ITEM,0,'Set Options','o',0,0,0,
        NM_ITEM,0,'Save Options','s',0,0,0,
        NM_TITLE,0,'Window',0,$0,0,0,
        NM_ITEM,0,'Iconify','i',0,0,0,
        NM_ITEM,0,'Expand','e',0,0,0,
        NM_TITLE,0,'ARexx',0,$0,0,0,
        NM_ITEM,0,'Not Yet Finnished',0,0,0,0,
        0,0,0,0,0,0,0]:newmenu,0))=NIL THEN Raise(ER_MENUS)
    IF LayoutMenusA(menu,visual,[GTMN_TEXTATTR,topaz,
                                 GTMN_NEWLOOKMENUS,TRUE,
                                 GTMN_FRONTPEN,1,
                                 GTMN_FULLMENU,TRUE])=FALSE THEN Raise(ER_MENUS)
    IF (g:=g_q:=CreateGadgetA(BUTTON_KIND,g,[245,83,82,15,'_quit',topaz,0,16,visual,1]:newgadget,
        [GT_UNDERSCORE,"_",NIL]))=NIL THEN Raise(ER_GADGET)
    IF (g:=g_l:=CreateGadgetA(BUTTON_KIND,g,[245,65,82,15,'_get',topaz,1,16,visual,1]:newgadget,
        [GT_UNDERSCORE,"_",NIL]))=NIL THEN Raise(ER_GADGET)
    IF (g:=g_a:=CreateGadgetA(BUTTON_KIND,g,[331,83,82,15,'about',topaz,2,16,visual,1]:newgadget,
        [GT_UNDERSCORE,"_",NIL]))=NIL THEN Raise(ER_GADGET)
    IF (g:=g_o:=CreateGadgetA(BUTTON_KIND,g,[331,65,82,15,'_options',topaz,3,16,visual,1]:newgadget,
        [GT_UNDERSCORE,"_",NIL]))=NIL THEN Raise(ER_GADGET)
    IF (g:=g_c:=CreateGadgetA(BUTTON_KIND,g,[245,47,82,15,'_iconify',topaz,8,16,visual,1]:newgadget,
        [GT_UNDERSCORE,"_",NIL]))=NIL THEN Raise(ER_GADGET)
    IF (g:=g_h:=CreateGadgetA(BUTTON_KIND,g,[331,47,82,15,'_help',topaz,9,16,visual,1]:newgadget,
        [GT_UNDERSCORE,"_",NIL]))=NIL THEN Raise(ER_GADGET)
    IF (g:=lv:=CreateGadgetA(LISTVIEW_KIND,g,[10,3,220,100,'',topaz,7,4,visual,0]:newgadget,
        [GTLV_LABELS,list,
         GTLV_READONLY,TRUE,
         NIL]))=NIL THEN Raise(ER_GADGET)
    IF (g:=p_lib:=CreateGadgetA(CHECKBOX_KIND,g,[245,7,310,1,'Check for Libs',topaz,4,2,visual,0]:newgadget,
        [GTCB_CHECKED,libs,
         NIL]))=NIL THEN Raise(ER_GADGET)
    IF (g:=p_dev:=CreateGadgetA(CHECKBOX_KIND,g,[245,20,310,1,'Check for Devs',topaz,5,2,visual,0]:newgadget,
        [GTCB_CHECKED,devs,
         NIL]))=NIL THEN Raise(ER_GADGET)
    IF (g:=p_fon:=CreateGadgetA(CHECKBOX_KIND,g,[245,33,310,1,'Check for Fonts',topaz,6,2,visual,0]:newgadget,
        [GTCB_CHECKED,font,
         NIL]))=NIL THEN Raise(ER_GADGET)
    IF (g:=CreateGadgetA(CHECKBOX_KIND,g,[440,7,310,1,'Output',topaz,10,2,visual,0]:newgadget,
        [GTCB_CHECKED,out,
         NIL]))=NIL THEN Raise(ER_GADGET)
    IF (g:=CreateGadgetA(CHECKBOX_KIND,g,[440,20,310,1,'Visual Work',topaz,11,2,visual,0]:newgadget,
        [GTCB_CHECKED,wor,
         NIL]))=NIL THEN Raise(ER_GADGET)
->    IF (g:=CreateGadgetA(MX_KIND,g,[442,55,310,1,'',topaz,12,2,visual,0]:newgadget,
->        [GTMX_LABELS,['Titlebar',
->                      'App Con',
->                      NIL],
->         NIL]))=NIL THEN Raise(ER_GADGET)
    IF (g:=CreateGadgetA(BUTTON_KIND,g,[440,83,42,15,'_ok!',topaz,13,16,visual,1]:newgadget,
        [GT_UNDERSCORE,"_",NIL]))=NIL THEN Raise(ER_GADGET)
    IF (g:=CreateGadgetA(BUTTON_KIND,g,[490,83,62,15,'_save',topaz,14,16,visual,1]:newgadget,
        [GT_UNDERSCORE,"_",NIL]))=NIL THEN Raise(ER_GADGET)
    IF (wnd:=OpenWindowTagList(NIL,
        [WA_LEFT,           0,
         WA_TOP,            11,
         WA_WIDTH,          440,
         WA_HEIGHT,         120,
         WA_IDCMP,          IDCMP_MOUSEBUTTONS OR
                            IDCMP_MENUPICK OR
                            IDCMP_GADGETUP OR
                            IDCMP_RAWKEY OR
                            IDCMP_CLOSEWINDOW OR
                            IDCMP_REFRESHWINDOW OR
                            LISTVIEWIDCMP,
         WA_FLAGS,          WFLG_SMART_REFRESH OR
                            WFLG_ACTIVATE OR
                            WFLG_GIMMEZEROZERO OR
                            WFLG_DRAGBAR OR
                            WFLG_HASZOOM OR
                            WFLG_DEPTHGADGET OR
                            WFLG_NEWLOOKMENUS,
         WA_CUSTOMSCREEN,   scr,
         WA_AUTOADJUST,     1,
         WA_GADGETS,        glist,
         WA_ACTIVATE,       TRUE,
         WA_ZOOM,           [10,10,100,11]:INT,
         WA_SCREENTITLE,    'Whats It Need v2.oo  (c)1996 Matthew Bushell',
         WA_TITLE,          'W.I.N v2.oo    Ready!',
         NIL]))=NIL THEN Raise(ER_WINDOW)
    IF SetMenuStrip(wnd,menu)=FALSE THEN Raise(ER_MENUS)
    DrawBevelBoxA(wnd.rport,235,3,195,100,[GT_VISUALINFO,visual,
                                           GTBB_RECESSED,TRUE,
                                           GTBB_FRAMETYPE,BBFT_RIDGE,0])
ENDPROC
->FEND
->FOLD PROC CLOSEDOWN
/*******************************[ PROC Closedown ]***************************/

PROC closedown()
    IF wnd THEN ClearMenuStrip(wnd)
    IF menu THEN FreeMenus(menu)
    IF topaz THEN StripFont(topaz)
    IF gadtoolsbase THEN CloseLibrary(gadtoolsbase)
    IF req THEN RtFreeRequest(req)
    IF reqtoolsbase THEN CloseLibrary(reqtoolsbase)
    IF scr THEN UnlockPubScreen(NIL,scr)
    IF wnd THEN CloseWindow(wnd)
    IF visual THEN FreeVisualInfo(visual)
    IF glist THEN FreeGadgets(glist)
ENDPROC
->FEND
->FOLD PROC INITLIST
/*******************************[ PROC initlist ]****************************/

PROC initlist(l:PTR TO mlh)
    /*-- Initialize an exec list. --*/
    l.head:=l+4
    l.tail:=NIL
    l.tailpred:=l
ENDPROC
->FEND
->FOLD PROC ADDTOLIST
/*******************************[ PROC addtolist ]***************************/

PROC addtolist()

DEF newNode=NIL:PTR TO ln,
    node:PTR TO ln,
    len,
    itemPosition=0

    IF (len:=StrLen(buffer))=0 THEN RETURN
    newNode:=New(SIZEOF ln)
    newNode.name:=String(len)
    StrCopy(newNode.name, buffer, ALL)
    Gt_SetGadgetAttrsA (lv,wnd,NIL,[GTLV_LABELS,-1,NIL])
    node:=list.head
    AddTail(list, newNode)
    Gt_SetGadgetAttrsA (lv,wnd,NIL,[GTLV_LABELS,list,
                                    GTLV_TOP,itemPosition,
                                    NIL])
ENDPROC
->FEND
->FOLD PROC KILLGADGETS
/********************************[ PROC killgadgets ]***************************/

PROC killgadgets(eh,a,b,c,d,e,f,g,h,i)
    IF a THEN Gt_SetGadgetAttrsA (p_lib,wnd,NIL,[GA_DISABLED,eh,NIL])
    IF b THEN Gt_SetGadgetAttrsA (p_dev,wnd,NIL,[GA_DISABLED,eh,NIL])
    IF c THEN Gt_SetGadgetAttrsA (p_fon,wnd,NIL,[GA_DISABLED,eh,NIL])
    IF d THEN Gt_SetGadgetAttrsA (g_l,wnd,NIL,[GA_DISABLED,eh,NIL])
    IF e THEN Gt_SetGadgetAttrsA (g_c,wnd,NIL,[GA_DISABLED,eh,NIL])
    IF f THEN Gt_SetGadgetAttrsA (g_h,wnd,NIL,[GA_DISABLED,eh,NIL])
    IF g THEN Gt_SetGadgetAttrsA (g_o,wnd,NIL,[GA_DISABLED,eh,NIL])
    IF h THEN Gt_SetGadgetAttrsA (g_q,wnd,NIL,[GA_DISABLED,eh,NIL])
    IF i THEN Gt_SetGadgetAttrsA (g_a,wnd,NIL,[GA_DISABLED,eh,NIL])
ENDPROC
->FEND
->FOLD PROC DOFILE
/********************************[ PROC dofile ]*****************************/

PROC dofile(lib,dev,fon)

DEF nobber,              -> File Handle
    itsname[16]:STRING,
    howmanylibs=0,
    howmanyfonts=0,
    howmanydevs=0,
    dafile[120]:STRING,  -> File Loading Variables
    count=0,             ->
    info:fileinfoblock,  ->
    size=0,              ->
    handle,              ->
    mem,                 ->
    read,                ->
    lock,                ->
    n,x,                 -> Loop Variables
    txt[7]:STRING,       -> Check against other text variables
    check[1]:STRING,     ->
    done=FALSE,          -> Finished yet?
    name[25]:STRING      -> Name of Library or Device or Font found.


    SetWindowTitles(wnd,'W.I.N v2.oo    Loading File to Process...             Options Mode',
                        'Whats It Need v2.oo  (c)1996 Matthew Bushell')
    list:=New(SIZEOF mlh)
    initlist(list)
    killgadgets(TRUE,1,1,1,1,1,1,1,1,1)
    buf[0]:=0
    itsname:='                          '
    IF RtFileRequestA(req,buf,'Select File To Scan',[RT_TEXTATTR,topaz,
                                                     RT_WINDOW,wnd,
                                                     NIL])
        StrCopy(dafile,req.dir)
        count:=StrLen(dafile)
        StrCopy(itsname,buf,16)
        IF StrCmp(dafile,'')
            StrCopy(dafile,buf)
        ELSE
            IF dafile[count-1]=58
                StrCopy(dafile,req.dir)
                StrAdd(dafile,buf)
            ELSE
                StrCopy(dafile,req.dir)
                StrAdd(dafile,'/',1)
                StrAdd(dafile,buf)
            ENDIF
        ENDIF
    ELSE
        killgadgets(FALSE,1,1,1,1,1,1,1,1,1)
        JUMP quit
    ENDIF
    IF (lock:=Lock(dafile,ACCESS_READ))=NIL
        RtEZRequestA(' cOULDNT lOCK sELECTED fILE qUITING oUT','_oK',0,0,[RT_UNDERSCORE,"_",RTEZ_REQTITLE,'WiN GUI fILE cHOICE eRROR'])
    ENDIF
    Examine(lock,info)
    size:=info.size
    UnLock(lock)
    IF (mem:=AllocVec(size,MEMF_PUBLIC))=NIL
        RtEZRequestA(' cOULDN`T aLLOCATE eNOUGH bYTES oF fREE mEMORY \n qUITING oUT','_oK',0,0,[RT_UNDERSCORE,"_",RTEZ_REQTITLE,'WiN GUI mEMORY eRROR'])
        JUMP quit
    ENDIF
    IF (handle:=Open(dafile,MODE_OLDFILE))=NIL
        RtEZRequestA(' cOULDNT oPEN sELECTED fILE qUITING oUT','_oK',0,0,[RT_UNDERSCORE,"_",RTEZ_REQTITLE,'WiN GUI fILE cHOICE eRROR'])
        FreeVec(mem)
        JUMP quit
    ENDIF
    IF (read:=Read(handle,mem,size))=NIL
        RtEZRequestA(' cOULDNT rEAD sELECTED fILE qUITING oUT','_oK',0,0,[RT_UNDERSCORE,"_",RTEZ_REQTITLE,'WiN GUI fILE cHOICE eRROR'])
        FreeVec(mem)
        JUMP quit
    ENDIF
    StrAdd(dafile,'.WiN',4)
    IF out=TRUE
        nobber:=Open(dafile,MODE_NEWFILE)
        IF nobber=NIL THEN JUMP quit
        Write(nobber,'WIN v2.oo - Output File',42)
        Write(nobber,10,1)
        Write(nobber,'FileName:',9)
        Write(nobber,itsname,16)
        Write(nobber,10,1)
        Write(nobber,'------------------------------------------',42)
    ENDIF
    SetWindowTitles(wnd,'W.I.N v2.oo    Processing File, Please Wait...',
                        'Whats It Need v2.oo  (c)1996 Matthew Bushell')
    FOR n:=1 TO size
        IF wor=TRUE
            MOVE.W $dff006,$DFF180       /*  lots  of pretty */
            MOVE.W $dff006,$DFF180       /*  colors! ahhhh!! */
        ENDIF
        StrCopy(txt,mem+n,7)
/*LIBS*/IF lib=TRUE
            IF txt[0]=46 AND txt[1]=108 AND txt[2]=105 AND txt[3]=98 AND txt[4]=114 AND txt[5]=97 AND txt[6]=114
                howmanylibs++
                x:=n
                REPEAT
                    x--
                    StrCopy(check,mem+x-1,1)
                    IF ((check[ZERO]>64) AND (check[ZERO]<91)) OR ((check[ZERO]>96) AND (check[ZERO]<123))
                    ELSE
                        done:=TRUE
                        StrCopy(name,mem+x,n-x)
                        StrAdd(name,mem+n,8)
                        StrCopy(buffer,name)
                        addtolist()
                        IF out=TRUE
                            Write(nobber,10,1)
                            Write(nobber,name,n-x+8)
                        ENDIF
                    ENDIF
                UNTIL done
                done:=FALSE
                done:=FALSE
            ENDIF
        ENDIF
/*DEV*/ IF dev=TRUE
            IF txt[0]=46 AND txt[1]=100 AND txt[2]=101 AND txt[3]=118 AND txt[4]=105 AND txt[5]=99 AND txt[6]=101
                howmanydevs++
                x:=n
                REPEAT
                    x--
                    StrCopy(check,mem+x-1,1)
                    IF ((check[ZERO]>64) AND (check[ZERO]<91)) OR ((check[ZERO]>96) AND (check[ZERO]<123))
                    ELSE
                        done:=TRUE
                        StrCopy(name,mem+x,n-x)
                        StrAdd(name,mem+n,7)
                        StrCopy(buffer,name)
                        addtolist()
                        IF out=TRUE
                            Write(nobber,10,1)
                            Write(nobber,name,n-x+8)
                        ENDIF
                    ENDIF
                UNTIL done=TRUE
                done:=FALSE
                done:=FALSE
            ENDIF
        ENDIF
/*FONT*/IF fon=TRUE
            IF txt[0]=46 AND txt[1]=102 AND txt[2]=111 AND txt[3]=110 AND txt[4]=116 /*AND txt[5]=99 AND txt[6]=101*/
                howmanyfonts++
                x:=n
                REPEAT
                    x--
                    StrCopy(check,mem+x-1,1)
                    IF ((check[ZERO]>64) AND (check[ZERO]<91)) OR ((check[ZERO]>96) AND (check[ZERO]<123))
                    ELSE
                        done:=TRUE
                        StrCopy(name,mem+x,n-x)
                        StrAdd(name,mem+n,5)
                        StrCopy(buffer,name)
                        addtolist()
                        IF out=TRUE
                            Write(nobber,10,1)
                            Write(nobber,name,n-x+5)
                        ENDIF
                    ENDIF
                UNTIL done
                done:=FALSE
                done:=FALSE
            ENDIF
        ENDIF
    ENDFOR
    FreeVec(mem)
    IF out=TRUE
        Write(nobber,10,1)
        Write(nobber,'------------------------------------------',42)
        Write(nobber,10,1)
        Write(nobber,'   WIN v2.oo (c)1996 by Matthew Bushell',40)
        Write(nobber,10,1)
        Close(nobber)
    ENDIF
    IF handle THEN Close(handle)
quit:
    x:=0
    check:=' '
    mem:=0
    n:=0
    killgadgets(FALSE,1,1,1,1,1,1,1,1,1)
    SetWindowTitles(wnd,'W.I.N v2.oo    Finished Processing... Ready!',
                        'Whats It Need v2.oo  (c)1996 Matthew Bushell')
ENDPROC
->FEND
->FOLD PROC SAVEPREFS
/********************************[ PROC saveprefs() ]************************/

PROC saveprefs()

DEF prefile -> File Handle

    IF (prefile:=Open('S:Win2.cfg',MODE_READWRITE))=NIL THEN Raise(ER_PREFS)
    IF out=TRUE
        Write(prefile,'O',1)
    ELSE
        Write(prefile,'o',1)
    ENDIF
    IF wor=TRUE
        Write(prefile,'V',1)
    ELSE
        Write(prefile,'v',1)
    ENDIF
    IF libs=TRUE
        Write(prefile,'L',1)
    ELSE
        Write(prefile,'l',1)
    ENDIF
    IF devs=TRUE
        Write(prefile,'D',1)
    ELSE
        Write(prefile,'d',1)
    ENDIF
    IF font=TRUE
        Write(prefile,'F',1)
    ELSE
        Write(prefile,'f',1)
    ENDIF
    Close(prefile)
ENDPROC
->FEND
->FOLD PROC LOADPREFS
/********************************[ PROC loadprefs() ]************************/

PROC loadprefs()

DEF carac[1]:STRING,
    prefile             -> File Handle

    IF (prefile:=Open('s:Win2.cfg',MODE_OLDFILE))=NIL THEN saveprefs()
    IF (prefile:=Open('s:Win2.cfg',MODE_OLDFILE))=NIL THEN saveprefs()
    Read(prefile,carac,1)
    IF StrCmp(carac,'o') THEN out:=FALSE
    IF StrCmp(carac,'O') THEN out:=TRUE
    Read(prefile,carac,1)
    IF StrCmp(carac,'v') THEN wor:=FALSE
    IF StrCmp(carac,'V') THEN wor:=TRUE
    Read(prefile,carac,1)
    IF StrCmp(carac,'l') THEN libs:=FALSE
    IF StrCmp(carac,'L') THEN libs:=TRUE
    Read(prefile,carac,1)
    IF StrCmp(carac,'d') THEN devs:=FALSE
    IF StrCmp(carac,'D') THEN devs:=TRUE
    Read(prefile,carac,1)
    IF StrCmp(carac,'f') THEN font:=FALSE
    IF StrCmp(carac,'F') THEN font:=TRUE
    Close(prefile)
ENDPROC
->FEND
->FOLD PROC DOABOUT
/******************************[ PROC doabout() ]***************************/

PROC doabout()

    SetWindowTitles(wnd,'W.I.N v2.oo    About this program:',
                        'Whats It Need v2.oo  (c)1996 Matthew Bushell')
    RtEZRequestA('                WIN - Whats It Need?               \n'+
                 '              Version 2 - Revision .00             \n'+
                 '                 by Matthew Bushell                \n'+
                 '              aka Maffia of Nerve Axis             \n'+
                 '             (c)1994-96 Matthew Bushell            \n'+
                 '                 Release Date (01/96)              \n\n'+
                 ' WIN - The one and only "Whats It Need? (To Run!)" \n'+
                 ' program.   Ever had a program not run, and it dont\n'+
                 ' tell you why?   Lame coders often dont bother with\n'+
                 ' "Cant find ReqTools, V39.xx", etc... messages,  so\n'+
                 ' thats were WIN comes in!  Just load the irritating\n'+
                 ' file into  "WIN2" and you`ll get a list of all the\n'+
                 ' Devices, Librarys and Fonts the program uses!     \n\n'+
                 '           !UNRGEISTERED VERSION! See Dox!   ','_NVX^96 & Beyond',0,0,[RT_UNDERSCORE,"_",
                                                                                         RT_TEXTATTR,topaz,
                                                                                         RTEZ_REQTITLE,' About WIN',
                                                                                         RT_WINDOW,wnd,NIL])
ENDPROC
->FEND
->FOLD PROC WAIT4MESSAGE
/******************************[ PROC wait4message ]*************************/

PROC wait4message(winda:PTR TO window)
  DEF g:PTR TO gadget
    type:=0
    key:=FALSE
    gadtool:=FALSE
   REPEAT
    IF mes:=Gt_GetIMsg(winda.userport)
      type:=mes.class
      IF type=IDCMP_MENUPICK
        infos:=mes.code
      ELSEIF type=IDCMP_RAWKEY
        infos:=mes.code
        key:=TRUE
      ELSEIF type=IDCMP_VANILLAKEY
        infos:=mes.code
      ELSEIF (type=IDCMP_GADGETDOWN) OR (type=IDCMP_GADGETUP)
        g:=mes.iaddress
        infos:=g.gadgetid
        gadtool:=TRUE
      ELSEIF type=IDCMP_REFRESHWINDOW
        Gt_BeginRefresh(winda)
        Gt_EndRefresh(winda,TRUE)
        type:=0
      ELSEIF type<>IDCMP_CLOSEWINDOW
        type:=0
      ENDIF
      Gt_ReplyIMsg(mes)
    ELSE
      Wait(-1)
    ENDIF
   UNTIL type<>0
ENDPROC
->FEND

->FOLD INCLUDES
/******************************[ Includes ]**********************************/

help: INCBIN 'help.txt'
blank: INCBIN 'blank.txt'
->FEND
->FOLD STUFF 2 DO
/******************************[ 2 DO ]**************************************\
**                                                                          **
** ID AND comment on Crunched files! Look at that e src                     **
** Only Move window on ABT & OPT if i have to                               **
** FIgure out how TO iconify                                                **
\****************************************************************************/
->FEND
