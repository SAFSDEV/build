/** 
 * Copyright (C) SAS Institute, All rights reserved.
 * General Public License: http://www.opensource.org/licenses/gpl-license.php
 */

/**
 * ResetCommitDate.java:
 * Logs for developers, not published to API DOC.
 *
 * History:
 * DEC 08 2015    (sbjlwa) Initial release.
 * DEC 14 2015    (sbjlwa) Copy org.safs.tools.consoles.ProcessCapture to this class to remove that dependency.
 *                         The sub-directories will be passed in one string (separated by ;) instead of multiple strings.
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
	
	public static void error(String message){
		System.err.println(message);
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
		int timeoutWaitProcess = 5000;
		
		if(!isValid(file)){
			error("The parameter file or repository is not valid!");
			return null;
		}

		String command = "git log --pretty=format:%cd -n 1 --date=iso "+file.getAbsolutePath();
		// iso date such as 2015-09-23 17:17:44 -0400

		try {
			Process p = Runtime.getRuntime().exec(command, null, gitRepository);
			ProcessCapture pc = new ProcessCapture(p);
			Thread thread = new Thread(pc);
			thread.start();
			thread.join(timeoutWaitProcess);

			if(pc.getExitValue()==0){
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
	
	public class ProcessCapture implements Runnable{
		protected Process process = null;
		/** time in milliseconds to pause to wait for stdout/stderr is ready. */
		protected  int pauseForReady = 10;
		protected BufferedReader  out = null;
		protected BufferedReader  err = null;
		protected boolean shutdown = false;
		protected  int exitValue = -1;
		
		public Vector<String> stdout = new Vector<String>();
		public Vector<String> stderr = new Vector<String>();
		
		public ProcessCapture(Process p){
			this.process = p;
			
			try{
				out = new BufferedReader(new InputStreamReader(process.getInputStream()));
				err = new BufferedReader(new InputStreamReader(process.getErrorStream()));
			}catch(Exception x){
				debug("ProcessCapture initialization error:"+ x.getMessage());
			}
		}
		
		public ProcessCapture(Process p, int pauseForReady){
			this(p);
			this.pauseForReady = pauseForReady;
		}

		public int getExitValue(){
			if(!shutdown){
				throw new IllegalThreadStateException("The process is still running ...");
			}
			return exitValue;
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
					
					try{
						exitValue = process.exitValue();
						shutdown = true;
					}catch(IllegalThreadStateException x){
						// process not yet finished
					}
					if ( !outdata && !errdata && !shutdown) Thread.sleep(pauseForReady);
					
				}
				
				debug("ProcessCapture shutdown for process "+ process);
				
			}catch(Exception x){
				debug("ProcessCapture thread loop error:"+ x.getMessage());
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
			System.out.println("Resetting 'last commit date' for files in repository '"+repository+"'");
				
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
					System.out.println("Resetting for files under folder '"+file.getAbsolutePath()+"'");
					reset.resetLastModifyTime(file);
				}else{
					error("parameter '"+subfolders[i]+"' is not a valid folder in repository");
				}
			}
		}
	}
}