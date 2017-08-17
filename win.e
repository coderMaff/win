/* Whats it need? v1.2 */

/* 1.00 - 1.19 Lost the code! ARgghhh! */
/* 1.2 - Total Re-Write */

CONST   ZERO=0

MODULE  'dos/dos',
        'exec/memory'

DEF     info:fileinfoblock,
        size,
        lock,
        handle,
        mem,
        read,
        n,
        txt[7]:STRING,
        x,check[1]:STRING,
        done=FALSE,
        name[25]:STRING

PROC main()
        WriteF('\nWin V1.2 by Maffia of Nerve Axis\n')
        WriteF('--------------------------------\n')
        IF arg[0] = NIL
                noarg()
                WriteF('--------------------------------\n')
        ELSE
                IF StrCmp(arg,'-?')
                        WriteF(' Whats It Need v1.2 \n')
                        WriteF(' Finds: Libs, Devs & Fonts in \n')
                        WriteF(' UNCRUNCHED! executables\n')
                        WriteF('\n--------------------------------\n')
                ELSE
                        dofile()
                        WriteF('--------------------------------\n')
                ENDIF
        ENDIF
ENDPROC

PROC noarg()
        WriteF('Syntax "Win <file>"\n')
ENDPROC

PROC dofile()

DEF     nobber, itsname[16]:STRING,
        howmanylibs=0,howmanyfonts=0,howmanydevs=0,where=1,dafile
        itsname:='                          '
        IF (lock:=Lock(arg,ACCESS_READ))=NIL
		WriteF('\nCouldn''t lock file "\s"!\n\n',arg)
                WriteF('--------------------------------\n')
		CleanUp(5)
	ENDIF
	Examine(lock,info)
	size:=info.size
	UnLock(lock)
	IF (mem:=AllocVec(size,MEMF_PUBLIC))=NIL
		WriteF('\nYou don''t have \d bytes of free memory...\n\n',size)
                WriteF('--------------------------------\n')
		CleanUp(5)
	ENDIF
	IF (handle:=Open(arg,MODE_OLDFILE))=NIL
		WriteF('\nCouldn''t open file "\s"!\n\n',arg)
		FreeVec(mem)
                WriteF('--------------------------------\n')
		CleanUp(5)
	ENDIF
	IF (read:=Read(handle,mem,size))=NIL
		WriteF('\nCouldn''t read file "\s"!\n\n',arg)
		FreeVec(mem)
                WriteF('--------------------------------\n')
		CleanUp(5)
	ENDIF


        FOR n:=1 TO size
            MOVE.W $dff006,$DFF180       /*  lots  of pretty */
            MOVE.W $dff006,$DFF180       /*  colors! ahhhh!! */

            StrCopy(txt,mem+n,7)
            IF txt[0]=46 AND txt[1]=108 AND txt[2]=105 AND txt[3]=98 AND txt[4]=114 AND txt[5]=97 AND txt[6]=114
                        WriteF('Library found: ')
                        x:=n
                        REPEAT
                                x--
                                StrCopy(check,mem+x-1,1)
                                IF ((check[ZERO]>64) AND (check[ZERO]<91)) OR ((check[ZERO]>96) AND (check[ZERO]<123))
                                ELSE
                                        done:=TRUE
                                        StrCopy(name,mem+x,n-x)
                                        StrAdd(name,mem+n,8)
                                        WriteF('\s\n',name)
                                ENDIF
                        UNTIL done
                        done:=FALSE
                        done:=FALSE
                ENDIF
                IF txt[0]=46 AND txt[1]=100 AND txt[2]=101 AND txt[3]=118 AND txt[4]=105 AND txt[5]=99 AND txt[6]=101
                        WriteF('Device found.: ')
                        x:=n
                        REPEAT
                                x--
                                StrCopy(check,mem+x-1,1)
                                IF ((check[ZERO]>64) AND (check[ZERO]<91)) OR ((check[ZERO]>96) AND (check[ZERO]<123))
                                ELSE
                                        done:=TRUE
                                        StrCopy(name,mem+x,n-x)
                                        StrAdd(name,mem+n,7)
                                        WriteF('\s\n',name)
                                ENDIF
                        UNTIL done
                        done:=FALSE
                        done:=FALSE
                ENDIF
                IF txt[0]=46 AND txt[1]=102 AND txt[2]=111 AND txt[3]=110 AND txt[4]=116 /*AND txt[5]=99 AND txt[6]=101*/
                        WriteF('Font found...: ')
                        x:=n
                        REPEAT
                                x--
                                StrCopy(check,mem+x-1,1)
                                IF ((check[ZERO]>64) AND (check[ZERO]<91)) OR ((check[ZERO]>96) AND (check[ZERO]<123))
                                ELSE
                                        done:=TRUE
                                        StrCopy(name,mem+x,n-x)
                                        StrAdd(name,mem+n,5)
                                        WriteF('\s\n',name)
                                ENDIF
                        UNTIL done
                        done:=FALSE
                        done:=FALSE
                ENDIF
        ENDFOR
        FreeVec(mem)
        Close(handle)
        x:=0
        check:=' '
        mem:=0
        n:=0
ENDPROC