/****** Object:  StoredProcedure [dbo].[DMJR_RETRIEVE_S68]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
 CREATE PROCEDURE [dbo].[DMJR_RETRIEVE_S68] (
     @An_Case_IDNO	NUMERIC(6)         
)        
AS  
  
/*  
 *     PROCEDURE NAME    : DMJR_RETRIEVE_S68  
 *     DESCRIPTION       : Retrieves Remedy details for the given Case ID
 *     DEVELOPED BY      : IMP Team    
 *     DEVELOPED ON      : 24-JAN-2011  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
*/  
    BEGIN  
  
      DECLARE 
         @Lc_CaseRelationshipCp_CODE		CHAR(1) = 'C',   
         @Lc_CaseRelationshipNcp_CODE		CHAR(1) = 'A',   
         @Lc_CaseRelationshipPutFather_CODE	CHAR(1) = 'P',
         @Lc_CaseMemberStatusActive_CODE	CHAR(1) = 'A',
         @Lc_Empty_TEXT						CHAR(1) = '',  
         @Lc_Space_TEXT						CHAR(1) = ' ',
         @Lc_Null_TEXT						CHAR(1) = NULL ,
         @Lc_HyphenWithSpace_TEXT			CHAR(3) = ' - ' ,
         @Lc_TableRela_ID					CHAR(4) = 'RELA',
         @Lc_TableSubCase_ID				CHAR(4) = 'CASE',  
         @Lc_TableSubSrct_ID				CHAR(4) = 'SRCT',   
         @Lc_TableSubRftp_ID				CHAR(4) = 'RFTP',
         @Lc_ActivityMajorMapp_CODE			CHAR(4) = 'MAPP',
         @Lc_ActivityMajorEstp_CODE			CHAR(4) = 'ESTP',
         @Lc_ActivityMajorRofo_CODE			CHAR(4) = 'ROFO', 
         @Lc_StatusStrt_CODE				CHAR(4) = 'STRT',
         @Lc_ActivityMinorAftbc_CODE		CHAR(5) = 'AFTBC',
         @Lc_ActivityMinorAserr_CODE		CHAR(5) = 'ASERR',
         @Lc_ActivityMinorAseri_CODE		CHAR(5) = 'ASERI',
         @Lc_ActivityMinorAnddi_CODE		CHAR(5) = 'ANDDI',
         @Lc_ActivityMinorAschd_CODE		CHAR(5) = 'ASCHD',
         @Lc_ActivityMinorAordd_CODE		CHAR(5) = 'AORDD',
         @Lc_ActivityMinorDocnm_CODE		CHAR(5) = 'DOCNM',
         @Lc_ActivityMinorFamup_CODE		CHAR(5) = 'FAMUP',
         @Lc_ActivityMinorRorof_CODE		CHAR(5) = 'ROROF', 
         @Ld_High_DATE						DATE	= '12/31/9999'; 
          
        SELECT m.MajorIntSeq_NUMB,
			 m.ActivityMajor_CODE,   
			 m.OthpSource_IDNO,   
			 m.Entered_DATE,   
			 m.Status_DATE,   
			 m.Status_CODE,   
			 m.ReasonStatus_CODE,   
			 m.Forum_IDNO,   
			 dbo.BATCH_COMMON$SF_GET_UNCHECKED_FORMS(m.Topic_IDNO, @Lc_Null_TEXT, @An_Case_IDNO, @Lc_Null_TEXT) AS DescriptionUncheckedForms_TEXT,
				(  
				   SELECT o.OtherParty_NAME  
				   FROM OTHP_Y1  o
				   WHERE o.OtherParty_IDNO = m.OthpSource_IDNO 
				     AND o.EndValidity_DATE = @Ld_High_DATE  
				) AS OtherParty_NAME,
			 m.TypeOthpSource_CODE,   
				 (  
				   SELECT  (r.Value_CODE + @Lc_HyphenWithSpace_TEXT + r.DescriptionValue_TEXT) AS DescriptionTypeOthpSource_CODE 
				   FROM REFM_Y1  r
				   WHERE r.Table_ID = m.ActivityMajor_CODE 
				     AND r.TableSub_ID = @Lc_TableSubSrct_ID 
				     AND r.Value_CODE = m.TypeOthpSource_CODE  
				) AS DescriptionTypeOthpSource_CODE,
			 m.TransactionEventSeq_NUMB,  
			 m.TypeReference_CODE,     
			 m.Reference_ID, 
			 CASE   
				WHEN m.TypeReference_CODE IN ( @Lc_CaseRelationshipCp_CODE, @Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE ) THEN   
				   (  
					  SELECT m.TypeReference_CODE + @Lc_HyphenWithSpace_TEXT + r1.DescriptionValue_TEXT AS DescriptionTypeReference_CODE  
					  FROM REFM_Y1 r1 
					  WHERE   
						 r1.Table_ID = @Lc_TableRela_ID 
					AND  r1.TableSub_ID = @Lc_TableSubCase_ID 
					AND  r1.Value_CODE = m.TypeReference_CODE  
				   )  
				WHEN  LTRIM(RTRIM(m.TypeReference_CODE)) <>@Lc_Empty_TEXT THEN   
				   (  
					  SELECT r2.Value_CODE + @Lc_HyphenWithSpace_TEXT + r2.DescriptionValue_TEXT AS DescriptionTypeReference_CODE  
					  FROM REFM_Y1 r2 
					  WHERE r2.Table_ID = m.ActivityMajor_CODE 
					    AND r2.TableSub_ID = @Lc_TableSubRftp_ID
					    AND r2.Value_CODE = m.TypeReference_CODE  
				   )  
				ELSE @Lc_Space_TEXT  
			 END AS DescriptionTypeReference_CODE,  
			 m.MinorIntSeq_NUMB, 
			 m.ActivityMinor_CODE,  
			 m.Topic_IDNO, 
			 m.UserLastPoster_ID, 
			 CONVERT(DATETIME2,m.LastPost_DTTM,20) AS LastPosted_DATE,
			 m.DescriptionNote_TEXT,
			 d.Last_NAME,
			 d.Suffix_NAME, 
			 d.First_NAME,
			 d.Middle_NAME 
      FROM (  
            SELECT MAX(k.Topic_IDNO) OVER(PARTITION BY k.Forum_IDNO) AS max_post,   
               j.MajorIntSeq_NUMB,   
               K.MinorIntSeq_NUMB,
               j.ReasonStatus_CODE,   
               j.OthpSource_IDNO,   
               CASE   
                  WHEN 
					  LTRIM(RTRIM( j.TypeOthpSource_CODE))=@Lc_Empty_TEXT THEN 
                     (  
                        SELECT a.CaseRelationship_CODE  
                        FROM CMEM_Y1  a  
                        WHERE a.Case_IDNO = @An_Case_IDNO 
                          AND a.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE 
                          AND j.OthpSource_IDNO = a.MemberMci_IDNO 
                          AND a.CaseRelationship_CODE IN ( @Lc_CaseRelationshipCp_CODE, @Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE )  
                     )  
                  ELSE j.TypeOthpSource_CODE  
               END AS TypeOthpSource_CODE,   
               j.ActivityMajor_CODE,   
               j.Status_CODE,   
               j.Forum_IDNO,   
               k.ActivityMinor_CODE,   
               l.DescriptionNote_TEXT,   
               k.UserLastPoster_ID,   
               k.LastPost_DTTM,   
               k.Topic_IDNO,   
               j.Entered_DATE,   
               j.Status_DATE,   
               j.TypeReference_CODE,   
               j.Reference_ID,   
               j.TransactionEventSeq_NUMB,   
               j.MemberMci_IDNO 
            FROM DMJR_Y1   j
			JOIN DMNR_Y1 k  
			  ON j.Case_IDNO = k.Case_IDNO 
			 AND j.Forum_IDNO = k.Forum_IDNO  
            LEFT JOIN NOTE_Y1 l   
			  ON l.Case_IDNO = k.Case_IDNO 
			 AND l.Topic_IDNO = k.Topic_IDNO 
			 AND l.Post_IDNO   = k.PostLastPoster_IDNO
			 AND l.EndValidity_DATE = @Ld_High_DATE
           WHERE j.Case_IDNO = @An_Case_IDNO    
             AND((	j.ActivityMajor_CODE = @Lc_ActivityMajorMapp_CODE
					AND k.ActivityMinor_CODE IN (@Lc_ActivityMinorDocnm_CODE,@Lc_ActivityMinorFamup_CODE)
					)
				OR (	j.ActivityMajor_CODE = @Lc_ActivityMajorEstp_CODE 
					AND  k.ActivityMinor_CODE IN (@Lc_ActivityMinorAftbc_CODE,@Lc_ActivityMinorAseri_CODE,@Lc_ActivityMinorAserr_CODE,@Lc_ActivityMinorAnddi_CODE,@Lc_ActivityMinorAschd_CODE,@Lc_ActivityMinorAordd_CODE)
					)
				OR (	j.ActivityMajor_CODE = @Lc_ActivityMajorRofo_CODE 
					AND  k.ActivityMinor_CODE IN (@Lc_ActivityMinorFamup_CODE,@Lc_ActivityMinorAnddi_CODE,@Lc_ActivityMinorRorof_CODE,@Lc_ActivityMinorAserr_CODE,@Lc_ActivityMinorAseri_CODE,@Lc_ActivityMinorAftbc_CODE)
					)
				)
			AND j.Status_CODE = @Lc_StatusStrt_CODE
			AND NOT EXISTS ( SELECT 1 
							   FROM FDEM_Y1   f
							 WHERE f.Case_IDNO = j.Case_IDNO
							   AND f.MajorIntSeq_NUMB = j.MajorIntSeq_NUMB
							   AND f.EndValidity_DATE = @Ld_High_DATE  )  
         )  AS m  LEFT JOIN
			DEMO_Y1 d 
				ON
					d.MemberMci_IDNO = m.OthpSource_IDNO
      WHERE m.Topic_IDNO = m.max_post  
      ORDER BY m.MajorIntSeq_NUMB DESC;  
                    
END;	--END OF DMJR_RETRIEVE_S68
  

GO
