/*  Simple "run-time" for the Pawn Abstract Machine, with optional support
 *  for debugging information and overlays.
 *
 *  Copyright (c) ITB CompuPhase, 1997-2011
 *
 *  Licensed under the Apache License, Version 2.0 (the "License"); you may not
 *  use this file except in compliance with the License. You may obtain a copy
 *  of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 *  WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 *  License for the specific language governing permissions and limitations
 *  under the License.
 *
 *  Version: $Id: pawnrun.c 4523 2011-06-21 15:03:47Z thiadmer $
 */

/*
 * NOTE: THIS FILE IS EXTENSIVELY CUSTOMIZED FOR AALTO-2
 * -Hannu Leppinen
 */

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <string.h>     /* for memset() (on some compilers) */
#include "osdefs.h"     /* for _MAX_PATH */
#include "amx.h"
#include "amxaux.h"

#include <time.h>
#if !defined CLOCKS_PER_SEC     /* some (older) compilers do not have it */
  #define CLOCKS_PER_SEC CLK_TCK
#endif

#if !defined AMX_NODYNALOAD && defined ENABLE_BINRELOC && (defined __LINUX__ || defined __FreeBSD__ || defined __OpenBSD__)
  #include <binreloc.h> /* from BinReloc, see www.autopackage.org */
#endif

#if defined AMXOVL
  #include "amxpool.h"
#endif
#if defined AMXDBG
  #include "amxdbg.h"
#endif
static char g_filename[_MAX_PATH];      /* for loading the debug or information
                                         * or for loading overlays */

/* These initialization functions are part of the "extension modules"
 * (libraries with native functions) that this run-time uses. More
 * extension modules may be dynamically linked (depending on whether
 * support for dynamic linking is enabled).
 */
extern int AMXAPI amx_ConsoleInit(AMX *amx);
extern int AMXAPI amx_CoreInit(AMX *amx);

AMX *global_amx;
int AMXAPI prun_Monitor(AMX *amx);


static int abortflagged = 0;
void sigabort(int sig)
{
  /* install the debug hook procedure if this was not done already */
  amx_SetDebugHook(global_amx,prun_Monitor);
  abortflagged=1;
  signal(sig,sigabort); /* re-install the signal handler */
}


typedef struct tagSTACKINFO {
  long maxstack, maxheap;
} STACKINFO;


/* prun_Monitor()
 * A simple debug hook, that allows the user to break out of a program
 * and that monitors stack usage. Note that the stack usage can only be
 * properly monitored when the debug hook is installed from the start
 * of the script to the end.
 */
int AMXAPI prun_Monitor(AMX *amx)
{
  int err;
  STACKINFO *stackinfo;

  /* record the heap and stack usage */
  err = amx_GetUserData(amx, AMX_USERTAG('S','t','c','k'), (void**)&stackinfo);
  if (err == AMX_ERR_NONE) {
    if (amx->stp - amx->stk > stackinfo->maxstack)
      stackinfo->maxstack = amx->stp - amx->stk;
    if (amx->hea - amx->hlw > stackinfo->maxheap)
      stackinfo->maxstack = amx->stp - amx->stk;
  } /* if */

  /* check whether an "abort" was requested */
  return abortflagged ? AMX_ERR_EXIT : AMX_ERR_NONE;
}


#if defined AMXOVL
/* prun_Overlay()
 * Helper function to load overlays
 */
int AMXAPI prun_Overlay(AMX *amx, int index)
{
  AMX_HEADER *hdr;
  AMX_OVERLAYINFO *tbl;
  FILE *ovl;

  assert(amx != NULL);
  hdr = (AMX_HEADER*)amx->base;
  assert((size_t)index < (hdr->nametable - hdr->overlays) / sizeof(AMX_OVERLAYINFO));
  tbl = (AMX_OVERLAYINFO*)(amx->base + hdr->overlays) + index;
  amx->codesize = tbl->size;
  amx->code = amx_poolfind(index);
  if (amx->code == NULL) {
    if ((amx->code = amx_poolalloc(tbl->size, index)) == NULL)
      return AMX_ERR_OVERLAY;   /* failure allocating memory for the overlay */
    ovl = fopen(g_filename, "rb");
    assert(ovl != NULL);
    fseek(ovl, (int)hdr->cod + tbl->offset, SEEK_SET);
    fread(amx->code, 1, tbl->size, ovl);
    fclose(ovl);
  } /* if */
  return AMX_ERR_NONE;
}
#endif


void ExitOnError(AMX *amx, int error)
{
  if (error != AMX_ERR_NONE) {
    #if defined AMXDBG
      FILE *fp;
      AMX_DBG amxdbg;
      long line;
      const char *filename;
    #endif

    printf("Run time error %d: \"%s\" on address %ld\n",
           error, aux_StrError(error), (long)amx->cip);

    /* optionally use the debug library to find the line number (if debug info.
     * is available)
     */
    #if defined AMXDBG
      /* load the debug info. */
      if ((fp=fopen(g_filename,"rb")) != NULL && dbg_LoadInfo(&amxdbg,fp) == AMX_ERR_NONE) {
        dbg_LookupFile(&amxdbg, amx->cip, &filename);
        dbg_LookupLine(&amxdbg, amx->cip, &line);
        printf("File: %s, line: %ld\n", filename, line);
        dbg_FreeInfo(&amxdbg);
        fclose(fp);
      } /* if */
    #endif
    exit(1);
  } /* if */
}


void PrintUsage(char *program)
{
  printf("Usage: %s <filename> [options]\n\n"
         "Options:\n"
         "\t-stack\tto monitor stack usage\n"
         "\t...\tother options are passed to the script\n"
         , program);
  exit(1);
}



#define PAWN_MEM_SIZE		16384
static uint8_t pawn_memory_area[PAWN_MEM_SIZE] = {0};


int main(int argc,char *argv[])
{
  AMX amx;
  cell ret = 0;
  int err, i;
  clock_t start,end;
  STACKINFO stackinfo = { 0 };
  AMX_IDLE idlefunc;

  if (argc < 2)
    PrintUsage(argv[0]);        /* function "usage" aborts the program */

  #if !defined AMX_NODYNALOAD && defined ENABLE_BINRELOC && (defined __LINUX__ || defined __FreeBSD__ || defined __OpenBSD__)
    /* see www.autopackage.org for the BinReloc module */
    if (br_init(NULL)) {
      char *libroot=br_find_exe_dir("");
      setenv("AMXLIB",libroot,0);
      free(libroot);
    } /* if */
  #endif

  /* Load the program and initialize the abstract machine. */
  err = aux_LoadProgram(&amx, argv[1], pawn_memory_area);
  if (err != AMX_ERR_NONE) {
    /* try adding an extension */
    char filename[_MAX_PATH];
    strcpy(filename, argv[1]);
    strcat(filename, ".amx");
    err = aux_LoadProgram(&amx, filename, pawn_memory_area);
    if (err != AMX_ERR_NONE)
      PrintUsage(argv[0]);
  } /* if */

  /* To install the debug hook "just-in-time", the signal function needs
   * a pointer to the abstract machine(s) to abort. There are various ways
   * to implement this; here I have done so with a simple global variable.
   */
  global_amx = &amx;
  signal(SIGINT, sigabort);

  /* Initialize two core extension modules (more extension modules may be
   * loaded & initialized automatically as DLLs or shared libraries.
   */
  amx_ConsoleInit(&amx);
  err = amx_CoreInit(&amx);
  ExitOnError(&amx, err);

  /* save the idle function, if set by any of the extension modules */
  if (amx_GetUserData(&amx, AMX_USERTAG('I','d','l','e'), (void**)&idlefunc) != AMX_ERR_NONE)
    idlefunc = NULL;

  for (i = 2; i < argc; i++) {
    if (strcmp(argv[i],"-stack") == 0) {
      uint16_t flags;
      amx_Flags(&amx, &flags);
      if ((flags & AMX_FLAG_NOCHECKS) != 0)
        printf("This script was compiled with debug information removed.\n"
               "Stack monitoring is disfunctional\n\n");
      /* Set "user data" with which the debug monitor can monitor stack usage
       * per abstract machine (in this example, though, there is only one abstract
       * machine, so a global variable would have sufficed).
       */
      memset(&stackinfo, 0, sizeof stackinfo);
      err = amx_SetUserData(&amx, AMX_USERTAG('S','t','c','k'), &stackinfo);
      ExitOnError(&amx, err);
      /* Install the debug hook, so that we can start monitoring the stack/heap
       * usage right from the beginning of the script.
       */
      amx_SetDebugHook(&amx, prun_Monitor);
    } /* if */
  } /* for */

  start=clock();

  /* Run the compiled script and time it. The "sleep" instruction causes the
   * abstract machine to return in a "restartable" state (it restarts from
   * the point that it stopped. This allows for a kind of light-weight
   * cooperative multi-tasking. As native functions (or the debug hook) can
   * also force an abstract machine to "sleep", you can also use it to create
   * "latent functions": functions that allow the host application to continue
   * processing, and/or other abstract machines to run, while they wait for
   * some resource.
   */
  err = amx_Exec(&amx, &ret, AMX_EXEC_MAIN);
  while (err == AMX_ERR_SLEEP) {
    if (idlefunc != NULL) {
      /* If the abstract machine was put to sleep, we can handle events during
       * that time. To save the "restart point", we must make a copy of the AMX
       * (keeping the stack, frame, instruction pointer and other vital
       * registers), but without cloning the entire abstract machine.
       * There should be some criterion on when the abstract machine must be
       * "woken up". In this example run-time, the parameter of the sleep
       * instruction is taken to be a delay in milliseconds. In your own host
       * application, you can choose to wait on a resource/semaphore or other.
       */
      AMX nested_amx = amx;
      clock_t stamp = clock();
      while (((clock() - stamp)*1000)/CLOCKS_PER_SEC < amx.pri
             && (err = idlefunc(&nested_amx,amx_Exec)) == AMX_ERR_NONE)
        /* nothing */;
      ExitOnError(&nested_amx, err);
    } /* if */
    err = amx_Exec(&amx, &ret, AMX_EXEC_CONT);
  } /* while */
  if (idlefunc == NULL || err != AMX_ERR_INDEX)
    ExitOnError(&amx, err);     /* event-driven programs may not have main() */

  /* For event-driven programs, we also need to loop over the idle/monitor
   * function that some extension module installed (this could be the console
   * module, for example). We did this if the main program was put to "sleep",
   * but we do that here too.
   */
  if (idlefunc != NULL) {
    while ((err = idlefunc(&amx,amx_Exec)) == AMX_ERR_NONE)
      /* nothing */;
    ExitOnError(&amx, err);
  } /* if */

  end=clock();

  /* Free the compiled script and resources. This also unloads and DLLs or
   * shared libraries that were registered automatically by amx_Init().
   */
  aux_FreeProgram(&amx);

  /* Print the return code of the compiled script (often not very useful),
   * its run time, and its stack usage.
   */
  if (ret!=0)
    printf("\nReturn value: %ld\n", (long)ret);

  printf("\nRun time:     %.2f seconds\n",(double)(end-start)/CLOCKS_PER_SEC);
  if (stackinfo.maxstack != 0 || stackinfo.maxheap != 0) {
    printf("Stack usage:  %ld cells (%ld bytes)\n",
           stackinfo.maxstack / sizeof(cell), stackinfo.maxstack);
    printf("Heap usage:   %ld cells (%ld bytes)\n",
           stackinfo.maxheap / sizeof(cell), stackinfo.maxheap);
  } /* if */

  #if defined AMX_TERMINAL
    /* This is likely a graphical terminal, which should not be closed
     * automatically
     */
    {
      extern int amx_termctl(int,int);
      while (amx_termctl(4,0))
        /* nothing */;
    }
  #endif

  return 0;
}


