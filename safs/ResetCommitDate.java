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
 */

import java.io.File;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Vector;

import org.safs.tools.consoles.GenericProcessConsole;
import org.safs.tools.consoles.ProcessCapture;

/**
 * Purpose: reset the file's last modified date to the git last-commi-date.<br>
 * 
 * Usage:<br>
 * java ResetCommitDate gitRepositoryDir subfolder1 subfolder2 ...<br>
 *
 */
public class ResetCommitDate{
	public static final String ISO_DATE_TIME = "yyyy-MM-dd HH:mm:ss Z";//2015-09-23 17:17:44 -0400
	public static boolean debug = false;
	
	private File gitRepository = null;
	
	public ResetCommitDate(File gitRepository){
		this.gitRepository = gitRepository;
	}
	
	public static void debug(String message){
		if(debug) System.out.println(message);
	}
	
	public static void error(String message){
		if(debug) System.err.println(message);
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
			ProcessCapture pc = new ProcessCapture(p, null, true);

			pc.thread.join(5000);
			Vector<String> out = pc.getData();

			if(out.size()>0){				
				String isoDateTime = out.get(0);
				debug(isoDateTime);
				
				isoDateTime = isoDateTime.substring(GenericProcessConsole.OUT_PREFIX.length());
				
				SimpleDateFormat format = new SimpleDateFormat(ISO_DATE_TIME);
				return format.parse(isoDateTime);
			}else{
				error("Got no result from command '"+command+"'");
				return null;
			}
			
		} catch (Exception e) {
			error("Met Exception "+e.getClass().getSimpleName()+" "+e.getMessage());
			return null;
		}
		
	}
	
	public static boolean isValid(File file){
		return (file!=null && file.exists());
	}
	
	public static void main(String[] args){
		if(args==null || args.length<2){
			error("java "+ResetCommitDate.class.getName()+" gitRepository folder1 [folder2] ....");
			return;
		}else{
			//Get the git repository
			File repository = new File(args[0]);
			if(!isValid(repository) || !repository.isDirectory()){
				error("The parameter gitRepository is not valid!");
				return;
			}
			System.out.println("Resetting 'last commit date' for files in repository '"+repository+"'");
				
			ResetCommitDate reset = new ResetCommitDate(repository);
			
			//get each folder and reset the files last modified date to the git last commit date
			File folder = null;
			for(int i=1;i<args.length;i++){
				folder = new File(repository, args[i]);
				if(!isValid(folder)) folder = new File(args[i]);
				if(isValid(folder)){
					System.out.println("Resetting for files under folder '"+folder.getAbsolutePath()+"'");
					reset.resetLastModifyTime(folder);
				}else{
					error("parameter '"+args[i]+"' is not a valid folder in repository");
				}
			}
		}
	}
}