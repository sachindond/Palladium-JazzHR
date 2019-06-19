/**
 * Developer	: Sachin/Vinit
 * Date 		: 27 Jan 2019
 * Purpose		: Wrapper class to hold Applicant,JobListing,JobApplication,Users,Questionaries from JazzHR Accounts
**/
public class JazzHRWrapper {

    // Applicant Wrapper
    public class ApplicantWrapper{
        public string id;
        public string first_name;
        public string last_name;
        public string email;
        public string address;
        public string location;
        public string phone;
        public string linkedin_url;
        public string eeo_gender;
        public string eeo_race;
        public string eeo_disability;
        public string website;
        public string desired_salary;
        public string desired_start_date;
        public string referrer;
        public string languages;
        public string wmyu;
        public string has_driver_license;
        public string willing_to_relocate;
        public string citizenship_status;
        public string education_level;
        public string has_cdl;
        public string over_18;
        public string can_work_weekends;
        public string can_work_evenings;
        public string can_work_overtime;
        public string has_felony;
        public string felony_explanation;
        public string twitter_username;
        public string college_gpa;
        public string college;
        public string references;
        public string notes;
        public string apply_date;
        public string comments_count;
        public string source;
        public string recruiter_id;
        public string eeoc_veteran;
        public string eeoc_disability;
        public string eeoc_disability_signature;
        public string eeoc_disability_date;
        public string resume_link;
        public string felony_explanaanswertion;
        
        //fields specific to bulk applicant fetch.
        public string prospect_phone;
        public string job_id;
        public string job_title;
        
        public List<Job> jobs;
        //public Job jobs;
        public List<QuestionnaireWrapper> questionnaire;
        //public string comments;
    }


    //Replicated the wrapper because JazzHR sends irregular format for single applicantion and multiple applications.
    //In future there will be possiblity of issues for questionnarie as well. We will take this up later.
    public class ApplicantWithSingleApplicationWrapper{
        public string id;
        public string first_name;
        public string last_name;
        public string email;
        public string address;
        public string location;
        public string phone;
        public string linkedin_url;
        public string eeo_gender;
        public string eeo_race;
        public string eeo_disability;
        public string website;
        public string desired_salary;
        public string desired_start_date;
        public string referrer;
        public string languages;
        public string wmyu;
        public string has_driver_license;
        public string willing_to_relocate;
        public string citizenship_status;
        public string education_level;
        public string has_cdl;
        public string over_18;
        public string can_work_weekends;
        public string can_work_evenings;
        public string can_work_overtime;
        public string has_felony;
        public string felony_explanation;
        public string twitter_username;
        public string college_gpa;
        public string college;
        public string references;
        public string notes;
        public string apply_date;
        public string comments_count;
        public string source;
        public string recruiter_id;
        public string eeoc_veteran;
        public string eeoc_disability;
        public string eeoc_disability_signature;
        public string eeoc_disability_date;
        public string resume_link;
        public string felony_explanaanswertion;
        
        //fields specific to bulk applicant fetch.
        public string prospect_phone;
        public string job_id;
        public string job_title;
        
        public Job jobs;
        //public Job jobs;
        public List<QuestionnaireWrapper> questionnaire;
        //public string comments;
    }

    //used specifically for sinple applicant
    public class Job
    {
        public string job_id;
        public string hiring_lead_rating;
        public string average_rating;
        public string workflow_step_id;
        public string job_title;
        public string applicant_progress;
    }

    // job listing wrapper
    public class JobListingWrapper{
   		public string id;
        public string team_id;
        public string title;
        public string country_id;
        public string city;
        public string state;
        public string zip;
        public string department;
        public string description;
        public string minimum_salary;
        public string maximum_salary;
        public string notes;
        public string original_open_date;
        public string type;
        public string status;
        public string send_to_job_boards;
        public string hiring_lead;
        public string board_code;
        public string internal_code;
        public string questionnaire;
    }
    // job Application wrapper
    public class JobApplicatonWrapper{
        public string id;
        public string applicant_id;
        public string job_id;
        public string rating;
        public string workflow_step_id;
        //public date date; Date keyword is reserved. So cannot map this in salesforce. Also api does not return valid value as such so no issues.
    }
    // Questionnaire Wrapper
    public  class QuestionnaireWrapper{
        public string question;
        public string answer;
    }
    // JazzHR User Wrapper
    public class UserWrapper{
        public string id;
        public string type;
        public string first_name;
        public string last_name;
        public string email;
        public date date_created;
    }
}