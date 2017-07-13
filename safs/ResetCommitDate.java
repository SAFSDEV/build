/** 
 * Copyright (C) SAS Institute, All rights reserved.
 * General Public License: http://www.opensource.org/licenses/gpl-license.php
 */

/**
 * ResetCommitDate.java:
 * Logs for developers, not published to API DOC.
 *
 * History:
 * DEC 08 2015    (Lei Wang) Initial release.
 * DEC 14 2015    (Lei Wang) Copy org.safs.tools.consoles.ProcessCapture to this class to remove that dependency.
 *                         The sub-directories will be passed in one string (separated by ;) instead of multiple strings.
 * DEC 15 2015    (Lei Wang) Fix a synchronization problem.
 * DEC 16 2015    (Lei Wang) Enlarge the timeout for waiting a process thread's termination.
 */

import java.io.BufferedReader;
import java.io.File;
import java.io.InputStreamReader;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Vector;

/**
 * Purpose: reset the file's last modified date to the git last-commi-date.<br>
 * 
 * Usage:<br>
 * java ResetCommitDate gitRepositoryDir subfolder1;subfolder2;subfolder3 [-debug|-d]<br>
 *
 */
public class ResetCommitDate{
	public static final String ISO_DATE_TIME 	= "yyyy-MM-dd HH:mm:ss Z";//2015-09-23 17:17:44 -0400
	public static final String SEPARATOR 		= ";";
	public static final String PARAM_DEBUG 		= "-debug";
	public static final String PARAM_D	 		= "-d";
	
	private static boolean debug = false;
	private File gitRepository = null;
	
	public ResetCommitDate(File gitRepository){
		this.gitRepository = gitRepository;
	}
	
	public static void debug(String message){
		if(debug) System.out.println(message);
	}
	
	public static void println(String message){
		System.out.println(message);
	}
	
	public static void error(String message){
		System.err.println("ERROR: "+message);
	}
	
	/**
	 * Reset the file's last modified date to the git-last-commit-date
	 * @param file
	 */
	public void resetLastModifyTime(File file){
		if(isValid(file)){
			
			if(file.isDirectory()){
				for(File f : file.listFiles()){
					resetLastModifyTime(f);
				}
			}else{
				Date date = getGitLastCommitDate(file);
				if(date!=null){
					if(!file.setLastModified(date.getTime())){
						error("Fail to reset file '"+file.getAbsolutePath()+"' last-modified-time to "+date.toString());
					}else{
						debug("reset '"+file.getAbsolutePath()+"' last modified date to "+date.toString());
					}
				}else{
					error("Fail to reset file '"+file.getAbsolutePath()+"' last-modified-time, the git-last-commit date is null.");
				}
			}
			
		}else{
			error("The parameter file is not valid!");
		}
	}
	
	public Date getGitLastCommitDate(File file){
		if(!isValid(file)){
			error("The parameter file or repository is not valid!");
			return null;
		}

		String command = "git log --pretty=format:%cd -n 1 --date=iso "+file.getAbsolutePath();
		// iso date such as 2015-09-23 17:17:44 -0400

		try {
			Process p = Runtime.getRuntime().exec(command, null, gitRepository);
			ProcessCapture pc = new ProcessCapture(p);
			
			if(pc.getExitValue(30)==0){
				if(pc.stdout.size()>0){
					String isoDateTime = pc.stdout.get(0);
					debug(isoDateTime);

					SimpleDateFormat format = new SimpleDateFormat(ISO_DATE_TIME);
					return format.parse(isoDateTime);
				}else{
					debug("Got no result from command '"+command+"'");
				}
			}else{
				error("The exit code is "+pc.exitValue);
			}
			if(pc.stderr.size()>0) for(String errmsg:pc.stderr) error(errmsg);
			return null;
			
		}catch (Exception e) {
			error("Met Exception "+e.getClass().getSimpleName()+" "+e.getMessage());
			return null;
		}

	}
	
	/**
	 * Start a sub-thread to capture the process's output from stdout and stderr.<br>
	 * By default, the main thread will wait this sub-thread to terminate with a timeout 30 seconds.<br>
	 * User can alternate that timeout by calling different constructor.<br>
	 * Then in the main thread:<br>
	 * 1. User can call {@link #getExitValue(int)} to test if the process terminates normally.<br>
	 *    This method expects the sub-thread's termination, if not terminated, then it will<br>
	 *    wait its termination for xxx seconds, if still not terminated, then throw out IllegalThreadStateException.<br>
	 * 2. User can get the process output from {@link #stdout} and {@link #stderr}.<br>
	 * 
	 */
	public static class ProcessCapture implements Runnable{
		public static final int DEFAULT_PAUSE_FOR_READY = 20;
		public static final int DEFAULT_TIME_WAIT_PROCESS = 30*1000;
		
		protected Process process = null;
		/** time in milliseconds to pause to wait for stdout/stderr is ready. */
		protected  int pauseForReady = DEFAULT_PAUSE_FOR_READY;
		/** timeout in milliseconds to wait for process thread terminates. */
		protected  int timeoutWaitProcess = DEFAULT_TIME_WAIT_PROCESS;
		
		protected BufferedReader  out = null;
		protected BufferedReader  err = null;
		protected boolean shutdown = false;
		protected  int exitValue = -1;
		
		
		public Vector<String> stdout = new Vector<String>();
		public Vector<String> stderr = new Vector<String>();
		
		public ProcessCapture(Process process){
			this(process, DEFAULT_PAUSE_FOR_READY, DEFAULT_TIME_WAIT_PROCESS);
		}
		
		public ProcessCapture(Process process, int pauseForReady){
			this(process, pauseForReady, DEFAULT_TIME_WAIT_PROCESS);
		}
		
		public ProcessCapture(Process process, int pauseForReady, int timeoutWaitProcess){
			this.process = process;
			this.pauseForReady = pauseForReady;
			this.timeoutWaitProcess = timeoutWaitProcess;
			
			try{
				out = new BufferedReader(new InputStreamReader(process.getInputStream()));
				err = new BufferedReader(new InputStreamReader(process.getErrorStream()));
				
				Thread thread = new Thread(this);
				thread.setDaemon(true);
				thread.start();
				long start = System.currentTimeMillis();
				thread.join(timeoutWaitProcess);
				debug("Time used "+(System.currentTimeMillis()-start));

			}catch(Exception x){
				debug("ProcessCapture initialization error:"+ x.getMessage());
			}
		}

		/**
		 * This method is used to test if the process terminates normally.<br>
		 * This method expects the sub-thread's termination, if not terminated, then it will<br>
		 * wait its termination for xxx seconds, if still not terminated, then throw out IllegalThreadStateException.<br>
		 * @param timeoutInSeconds int, the timeout in seconds to get process's exit value.
		 * @return int, the process's exit value. 0 means normal.
		 */
		public int getExitValue(int timeoutInSeconds){
			if(!isShutdown()){
				println("waitting for process thread terminates for another 10 seconds ... ");
				int tries = 0;
				while(!isShutdown() && tries++<timeoutInSeconds){
					try{ Thread.sleep(1000);}catch(Exception e){}
				}
			}
			if(!isShutdown()){
				throw new IllegalThreadStateException("The process is still running ...");
			}
			return exitValue;
		}
		
		protected synchronized void setShutdown(boolean shutdown){
			this.shutdown = shutdown;
		}
		protected synchronized boolean isShutdown(){
			return shutdown;
		}
		
		public void run(){
			boolean outdata = true;
			boolean errdata = true;
			String linedata = null;
			try{
				while(!shutdown){
					outdata = out.ready();
					if (outdata) {
						linedata = out.readLine();
						if (linedata!=null && linedata.length()>0){
							stdout.add(linedata);
						}
					}
					
					errdata = err.ready();
					if (errdata) {
						linedata = err.readLine();
						if (linedata!=null && linedata.length()>0){
							stderr.add(linedata);
						}
					}
					
					if (!outdata && !errdata){
						try{
							exitValue = process.exitValue();
							setShutdown(true);
						}catch(IllegalThreadStateException x){
							// process not yet finished
						}
						
						if (!shutdown) try{ Thread.sleep(pauseForReady);}catch(Exception e){}
					}
					
				}
				
				debug("ProcessCapture shutdown for process "+ process+" shutdown="+shutdown+" exitValue="+exitValue);
				
			}catch(Throwable x){
				error("ProcessCapture thread loop error:"+ x.getMessage()+" shutdown="+shutdown+" exitValue="+exitValue);
			}
		}
		
	}
	
	public static boolean isValid(File file){
		return (file!=null && file.exists());
	}
	
	public static String getUsage(){
		return "Usage: java "+ResetCommitDate.class.getName()+" gitRepository subFolders [-debug|-d]\n"
			         + "subFolders is "+SEPARATOR+" separated string, such as subfolder1"+SEPARATOR+"subfoder2"+SEPARATOR+"subfolder3";
	}
	
	/**
	 * Usage:<br>
	 * java ResetCommitDate gitRepositoryDir subfolder1;subfolder2;subfolder3 [-debug|-d]<br>
	 * 
	 * @param args <br>
	 * args[0] required gitRepositoryDir<br>
	 * args[1] required subFolders<br>
	 * args[2] optional -debug<br>
	 */
	public static void main(String[] args){
		if(args==null || args.length<2){
			error("The number of parameters is not enough.\n"+getUsage());
			return;
		}else{
			//Get the git repository
			File repository = new File(args[0]);
			if(!isValid(repository) || !repository.isDirectory()){
				error("The parameter gitRepository is not valid!\n"+getUsage());
				return;
			}
			println("Resetting 'last commit date' for files in repository '"+repository+"'");
				
			ResetCommitDate reset = new ResetCommitDate(repository);
			
			//get each folder and reset the files last modified date to the git last commit date
			String subFolders = args[1];
			try{
				if(args.length>2) debug = PARAM_DEBUG.equalsIgnoreCase(args[2]) || PARAM_D.equalsIgnoreCase(args[2]);
			}catch(Exception e){}
			
			if(subFolders==null || subFolders.trim().isEmpty()){
				error("The parameter subFolders is not valid!\n"+getUsage());
				return;
			}
			
			String[] subfolders = subFolders.split(SEPARATOR);
			String subfolder = null;
			File file = null;
			
			for(int i=0;i<subfolders.length;i++){
				subfolder = subfolders[i];
				if(subfolder!=null) subfolder = subfolder.trim();
				file = new File(repository, subfolder);
				if(!isValid(file)) file = new File(subfolder);
				if(isValid(file)){
					println("Resetting for files under folder '"+file.getAbsolutePath()+"'");
					reset.resetLastModifyTime(file);
				}else{
					error("parameter '"+subfolders[i]+"' is not a valid folder in repository");
				}
			}
		}
	}
}