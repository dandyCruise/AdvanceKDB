///////////////////////////////////////////////////////////////////////
// File:      cron.q - Scheduled command utilities.
//
// Header:
//  This module manages scheduled events.
//
//  Usage:
//    .cron.add[string command; initial time or 0 (now); repeat mode <`once|`repeat|`cmdresult>; repeat interval]
//    .cron.add returns an event id assigned to this event
//
//    .cron.get[event id]
//
//    .cron.remove[event id]
//
//  Notes on usage:
//    1. If the initial time is less then current time then it is scheduled for now (represented as 0).
//    2. Events scheduled to run repeatedly will run until removed from the cron.
//    3. Events can be scheduled to repeat depending on the result of the command.  If the command returns
//       a non-zero result, it is scheduled to run in 'repeat interval' seconds.  If the command returns
//       a zero or fails, it is removed from the cron.
//
///////////////////////////////////////////////////////////////////////


///////////////////////////////////////////////////////////////////////
// Variable: .cron.Events
//
//  Events (i.e. schduled commands) that have been registered with
//  this module using <.cron.add>.
///////////////////////////////////////////////////////////////////////
.cron.Events:([]
    cmdId:`long$();          / Id of the command
    cmd:();                 / The command to run as a string
    nextRun:`timestamp$();   / The next time to run this command (see .cron.run)
    repeatMode:`symbol$();  / The repeat type to use (one of `once`repeat`cmdresult)
    repeatInterval:`long$()  / The interval to repeat the command at in seconds
 );

///////////////////////////////////////////////////////////////////////
// Variable: .cron.id
//
//  The currently last ID to use when inserting jobds into <.cron.Events>
///////////////////////////////////////////////////////////////////////
.cron.id:0


///////////////////////////////////////////////////////////////////////
// Function: .cron.getId
//
//  Get the next ID to use when adding command to run to <.cron.Events>
//
//  Returns:
//      The ID to use when registering a command in <.cron.Events>.
//      The number is guaranteed to be larger than, or equal to, one.
///////////////////////////////////////////////////////////////////////
.cron.getId:{:.cron.id+:1}

///////////////////////////////////////////////////////////////////////
// Function: .cron.get
//
//  Get the event with the specified ID.
//
//  Parameters:
//      id      - The ID to get the event from.
//
//  Returns:
//      The event registered under the specified ID.
///////////////////////////////////////////////////////////////////////
.cron.get:{[id]first exec from .cron.Events where cmdId = id}

///////////////////////////////////////////////////////////////////////
// Function: .cron.add
//
//  Add a command to run to the list of commands
//
//  Parameters:
//      cmd             - The command to evaluate as  a string.
//      nextRun         - The next time to run a command as either a date time
//                        or in seconds (time zone assumed to be GMT).
//      repeatMode      - The mode to repeat the commands, can be either of
//                        `once`repeat`cmdresult. if specifying `cmdresult,
//                        the module will keep running the command as long as
//                        it doesn't fail.
//      repeatInterval  - The inteval at which to repeat the command in seconds.
//
//  Returns:
//      The ID that the the registered event is stored under.
//
//  Examples:
//      (start example)
//          .cron.add["e0+:1;e0"; .z.z            ; `once;      0]
//          .cron.add["e0+:1;e0"; ("v"$.z.z)      ; `once;      0]
//          .cron.add["e1+:1;e1"; ("v"$.z.z)+60   ; `repeat;    2]
//          .cron.add["e1+:1;e1"; .z.z)           ; `repeat;    2]
//          .cron.add["e2:2;e2";  ("v"$.z.z)-10000; `repeat;    3]
//          .cron.add["e3-:1;e3"; ("v"$.z.z)-10000; `cmdresult; 4]
//          .cron.add["e4:4;e4";  ("v"$.z.z)-10000; `cmdresult; 5]
//          .cron.add["e5+:5;e5"; 0;                `repeat;    6]
//      (end example)
///////////////////////////////////////////////////////////////////////
.cron.add:{[cmd; nextRun; repeatMode; repeatInterval]
    / Ensure proper repeat mode
    if[not repeatMode in `once`repeat`cmdresult;
        '"Illegal repeatMode: ",string repeatMode];

    / Ensure proper repeat interval
    if[-7h <> type repeatInterval;
        '"Illegal non-integer repeatInterval ",string repeatInterval];
    if[0>repeatInterval;
        '"Illegal negative repeatInterval ",string repeatInterval];
    if[(repeatMode=`once) and 0<>repeatInterval;
        '"Illegal repeat interval, must be = 0 for mode `once"];
    if[(repeatMode<>`once) and 1>repeatInterval;
        '"Illegal repeatInterval, must be >= 1 for any mode except `once"];

    / Small utility function to add int or time onto a datetime
    / (note that this is needed by Q 2.3)
    addTime:{dt:.z.z; (`date$dt) + `time$(`time$dt) + `time$x};

    / Ensure a proper datetime is created to indicate when
    / the command should run next
    if[ -7h=type nextRun; nextRun:addTime[`second$nextRun]]; / Handle int        (0)
    if[-18h=type nextRun; nextRun:addTime[nextRun]];         / Handle seconds    (12:00:00)
    if[-19h=type nextRun; nextRun:(`date$.z.z) + nextRun];   / Handle time       (12:00:00.000)

    / Get the ID and insert the command into the table
    newId: .cron.getId[];

    `.cron.Events insert (newId; cmd; nextRun; repeatMode; repeatInterval);

    :newId
    }

///////////////////////////////////////////////////////////////////////
// Function: .cron.remove
//
//  Remove a command from the list of commands
//
//  Parameters:
//      id              - The id of the command to remove
///////////////////////////////////////////////////////////////////////
.cron.remove:{[id]delete from `.cron.Events where cmdId = id;}

///////////////////////////////////////////////////////////////////////
// Function: .cron.run
//
//  Run commands due to run in <.cron.Events>, removing any `once marked
//  jobs or jobs that fails and have been marked `cmdresult.
//  The times for when to run the jobs the next time is incremented
//  as is appropriate for jobs that are ran (respecting the repeatInterval).
///////////////////////////////////////////////////////////////////////
.cron.run:{[]
    / Get all jobs that are due by this time
    events: select from .cron.Events where nextRun <= .z.z;

    / Execute it. The called function will update / remove the
    / job as is appropriate
    .cron.runEvent each events;
 }

///////////////////////////////////////////////////////////////////////
// Function: .cron.runEvent
//
//  Runs a schdeuled command, where the command is a row from <.cron.Events>.
//  The command will be updated / removed as is appropriate.
//
//  Parameters:
//      event   - The command to run (a row from <.cron.Events>)
///////////////////////////////////////////////////////////////////////
.cron.runEvent:{[event]
    .log4q.DEBUG "[cron.q] Executing event: ",-3!event;

    / Execute the command
    res:@[{(`ok; value x)}; event[`cmd]; {[err] (`error;err)}];

    / Report error. Whether to keep running the command or not
    / is dediced below
    if[`error=first res;
        .log4q.INFO "Event ",(-3!event)," failed: ",last res];

    / It was supposed to run once, remove it and return
    if[`once=event`repeatMode;
        .log4q.DEBUG "[cron.q] Event was `once, removing";
        delete from `.cron.Events where cmdId = event[`cmdId];
        :0];

    / It failed, or returned zero, and was a `cmdresult typed event
    if[(`cmdresult=event`repeatMode) and ((`error=first res) or (0~last res));
        .log4q.DEBUG "[cron.q] Event was `cmdresult and the command failed or returned zero, removing";
        delete from `.cron.Events where cmdId = event[`cmdId];
        :0];

    / At this point, it has been assertained that the job has succeeded
    / and is a `cmdresult typed job or is a `repeat job. Reschedule it.
    / The incredible amount of casting are due to the limited support of
    / the '+' operation for temporal types in KDB+ prior to version 2.6

    nextRun: .z.z;  / Note that this removes dodgy handling times around midnight
    nextStep:event`repeatInterval;
    newTime:(`date$nextRun)+`time$(`time$nextRun)+`time$`second$nextStep;
    update nextRun:newTime from `.cron.Events where cmdId = event[`cmdId];
 }

///////////////////////////////////////////////////////////////////////
// Variable: .z.t
//
//  Override the KDB+ built-in event timer function; this function is
//  executed by specifying the amount of milliseconds between each
//  run using the \t command (set to 1000ms in this module).
///////////////////////////////////////////////////////////////////////
.z.ts:{.cron.run[]}     / execute run as the KDB+ event function
system"t 1000"          / run it every second


