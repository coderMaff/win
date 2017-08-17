/*  Whats It Need? v1.01 Beta by Maffia of Nerve Axis*/
/* */
/* History */
/* v1.01 well, i decided to keep the cli version up to scratch */
/*       so the new code has been added! And the Lib Grabbing  */
/*       is now as acurate as WinguiV1.05                      */

MODULE	'dos/dos','exec/memory'

DEF	info:fileinfoblock,size,lock,handle,mem,read,n,txt[7]:STRING,
        x,check[1]:STRING,name[25]:STRING,done=FALSE

PROC main()
   WriteF('\n Whats It Need? v1.01 by Maffia Nerve Axis\n')
   WriteF('-------------------------------------------\n')
   IF arg[0]=NIL
        WriteF('Syntax :  Win <Executable> \n')
        WriteF('')
   ELSE
	IF	(lock:=Lock(arg,ACCESS_READ))=NIL
		WriteF('\nCouldn''t lock file "\s"!\n\n',arg)
		CleanUp(5)
	ENDIF
	Examine(lock,info)
	size:=info.size
	UnLock(lock)
	IF	(mem:=AllocVec(size,MEMF_PUBLIC))=NIL
		WriteF('\nYou don''t have \d bytes of free memory...\n\n',size)
		CleanUp(5)
	ENDIF
	IF	(handle:=Open(arg,MODE_OLDFILE))=NIL
		WriteF('\nCouldn''t open file "\s"!\n\n',arg)
		FreeVec(mem)
		CleanUp(5)
	ENDIF
	IF	(read:=Read(handle,mem,size))=NIL
		WriteF('\nCouldn''t read file "\s"!\n\n',arg)
		FreeVec(mem)
		CleanUp(5)
	ENDIF
        FOR n:=1 TO size
                StrCopy(txt,mem+n,7)
                IF txt[0]=46 AND txt[1]=108 AND txt[2]=105 AND txt[3]=98 AND txt[4]=114 AND txt[5]=97 AND txt[6]=114
                        WriteF('library found : ')
                        x:=n
                        REPEAT
                                x--
                                StrCopy(check,mem+x-1,1)
                                IF ((check[0]>64) AND (check[0]<91)) OR((check[0]>96) AND (check[0]<123))
                                ELSE
                                        done:=TRUE
                                ENDIF
                                IF done=TRUE
                                        StrCopy(name,mem+x,n-x+8)
                                        WriteF('\s\n',name)
                                ENDIF
                        UNTIL done
                        done:=FALSE
                ENDIF
        ENDFOR
        Close(handle)
	FreeVec(mem)
   ENDIF
   WriteF('-------------------------------------------\n')
   WriteF('Remember some of these libs are rom based!\n\n')
   CleanUp(0)
ENDPROC
