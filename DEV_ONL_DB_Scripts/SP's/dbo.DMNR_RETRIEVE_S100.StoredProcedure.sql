/****** Object:  StoredProcedure [dbo].[DMNR_RETRIEVE_S100]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DMNR_RETRIEVE_S100] (
 @An_Case_IDNO      NUMERIC(6, 0),
 @An_Forum_IDNO     NUMERIC(10, 0),
 @An_DateDiff_NUMB  NUMERIC(7, 2),
 @Ac_SortBy_TEXT    CHAR(30),
 @Ac_SortOrder_TEXT CHAR(4)
 )
AS
 /*  
 *      PROCEDURE NAME    : DMNR_RETRIEVE_S100  
  *     DESCRIPTION       : Retrieve Minor activity reference details for a Case ID, Forum ID, Sequence Number for the Remedy and Case / Order combination.  
  *     DEVELOPED BY      : IMP Team  
  *     DEVELOPED ON      : 17-AUG-2011
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
 */
 BEGIN
  DECLARE @Lc_NoticeExistsNo_INDC  CHAR(1) = 'N',
          @Lc_NoticeExistsYes_INDC CHAR(1) = 'Y',
          @Ls_Sql_TEXT             VARCHAR(MAX)='',
          @Ld_High_DATE            DATE ='12/31/9999',
          @Ld_Systemdate_DATE      DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

  SET @Ls_Sql_TEXT ='
    SELECT 
      X.MajorIntSeq_NUMB ,         
      X.MinorIntSeq_NUMB ,         
      X.ActivityMinor_CODE ,       
      X.Status_CODE ,              
      X.Topic_IDNO ,               
      X.TotalViews_QNTY,           
      X.UserLastPoster_ID ,        
      X.LastPost_DTTM,             
      X.TransactionEventSeq_NUMB , 
      X.ActivityMajor_CODE ,       
      X.Subsystem_CODE ,           
      X.DescriptionNote_TEXT ,     
      X.OthpSource_IDNO ,          
      X.TypeOthpSource_CODE,       
      X.DescriptionActivityMajor_TEXT,
      X.DescriptionActivityMinor_TEXT,
      X.DescriptionUnCheckedNotices_TEXT,
      CASE 
         WHEN Notice_ID IS NULL 
          THEN ''' + @Lc_NoticeExistsNo_INDC + ''' 
         ELSE ''' + @Lc_NoticeExistsYes_INDC + ''' 
      END NoticeExists_INDC
      FROM
      (
      SELECT
       	a.MajorIntSeq_NUMB ,   
        a.MinorIntSeq_NUMB ,
        a.ActivityMinor_CODE , 
        a.Status_CODE ,
        a.Topic_IDNO ,
        a.TotalViews_QNTY,
        a.UserLastPoster_ID ,          
        a.LastPost_DTTM,
        a.TransactionEventSeq_NUMB , 
        a.ActivityMajor_CODE ,
        a.Subsystem_CODE ,   
        b.DescriptionNote_TEXT ,
        c.OthpSource_IDNO ,   
        c.TypeOthpSource_CODE,
        (  
             SELECT 
             	DISTINCT y.DescriptionActivity_TEXT  
              FROM 
             	AMJR_Y1  y
             WHERE 
             	 y.ActivityMajor_CODE = a.ActivityMajor_CODE 
             AND 
             	 y.EndValidity_DATE = ''' + CONVERT(VARCHAR, @Ld_High_DATE) + ''' 
        ) AS DescriptionActivityMajor_TEXT,   
        (  
             SELECT 
             	DISTINCT z.DescriptionActivity_TEXT  
              FROM 
             	AMNR_Y1  z
             WHERE 
             	z.ActivityMinor_CODE = a.ActivityMinor_CODE 
             AND 
             	z.EndValidity_DATE = ''' + CONVERT(VARCHAR, @Ld_High_DATE) + '''  
        ) AS DescriptionActivityMinor_TEXT,   
        dbo.BATCH_COMMON$SF_GET_UNCHECKED_FORMS(a.Topic_IDNO, NULL, a.Case_IDNO, NULL) AS DescriptionUnCheckedNotices_TEXT,
           (
              SELECT TOP 1 Notice_ID
                FROM
               	FORM_Y1  c
               WHERE
                  c.Topic_IDNO = a.Topic_IDNO
            ) AS Notice_ID  
       FROM   
        DMNR_Y1  a   
      LEFT OUTER JOIN 
      	NOTE_Y1 b   
            ON   
               	  a.Case_IDNO = b.Case_IDNO    
             AND  
             	  a.Topic_IDNO = b.Topic_IDNO    
             AND  
             	  b.Post_IDNO = a.PostLastPoster_IDNO
             AND 
				  b.EndValidity_DATE = ''' + CONVERT(VARCHAR, @Ld_High_DATE) + '''
      JOIN   
      	DMJR_Y1 c 
      		ON
      			  a.MajorIntSeq_NUMB = c.MajorIntSeq_NUMB
      		 AND 
      		 	  a.Case_IDNO = c.Case_IDNO
      		 AND 
      			  a.Forum_IDNO = c.Forum_IDNO
      WHERE 
           	a.Case_IDNO = ' + CONVERT(VARCHAR, @An_Case_IDNO) + '
      AND 
      		a.Forum_IDNO = ' + CONVERT(VARCHAR, @An_Forum_IDNO) + '
      AND 
      		a.Entered_DATE BETWEEN CONVERT(DATE,DATEADD(D,-CAST (' + CONVERT(VARCHAR, @An_DateDiff_NUMB) + ' AS FLOAT (53)),''' + CONVERT(VARCHAR, @Ld_Systemdate_DATE) + '''))AND ''' + CONVERT(VARCHAR, @Ld_Systemdate_DATE) + '''
      ) AS X ORDER BY ' + @Ac_SortBy_TEXT + ' ' + @Ac_SortOrder_TEXT;

  EXEC (@Ls_Sql_TEXT);
 END; --End of DMNR_RETRIEVE_S100  


GO
