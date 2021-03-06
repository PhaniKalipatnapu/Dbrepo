/****** Object:  StoredProcedure [dbo].[UDMNR_RETRIEVE_S9]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UDMNR_RETRIEVE_S9] (
 @An_Case_IDNO          NUMERIC(6, 0),
 @Ac_ActivityMajor_CODE CHAR(4),
 @Ac_Subsystem_CODE     CHAR(2),
 @Ac_SortBy_TEXT        CHAR(30),
 @Ac_SortOrder_TEXT     CHAR(4),
 @An_DateDiff_NUMB      NUMERIC(9, 2),
 @Ac_WorkerUpdate_ID    CHAR(30),
 @Ai_RowFrom_NUMB       INT = 1,
 @Ai_RowTo_NUMB         INT = 10
 )
AS
 /*
  *     PROCEDURE NAME    : UDMNR_RETRIEVE_S9
  *     DESCRIPTION       : Retrieve Description of the Activity, Subsystem of the Child Support system, Topic ID, Sequence number for every new Minor Activity and etc., for a Case ID and Subsystem of the Child Support system.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 18-AUG-2011
  *     MODIFIED BY       :
  *     MODIFIED ON       :
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Li_Zero_NUMB                INT			= 0,
          @Lc_NoticeExistsNo_INDC      CHAR(1)		= 'N',
          @Lc_NoticeExistsYes_INDC     CHAR(1)		= 'Y',
          @Lc_StatusNoticeT_CODE       CHAR(1)		= 'T',
          @Lc_Empty_TEXT               CHAR(1)		= '',
          @Lc_Percentage_TEXT          CHAR(1)		= '%',
          @Lc_HyphenWithSpace_TEXT     CHAR(3)		= ' - ',
          @Lc_StatusComplete_CODE      CHAR(4)		= 'COMP',
          @Lc_StatusExempt_CODE        CHAR(4)		= 'EXMT',
          @Lc_TableCPRO_ID             CHAR(4)		= 'CPRO',
          @Lc_TableSubREAS_ID          CHAR(4)		= 'REAS',
          @Lc_ActivityMinorNOPRI_CODE  CHAR(5)		= 'NOPRI',
          @Lc_SortOrder_TEXT		   CHAR(4)		= 'DESC',
          @Ls_WhereWorkerUpdateID_TEXT VARCHAR(100)	= '',
          @Ls_Sql1_TEXT                VARCHAR(MAX)	= '',
          @Ls_Sql2_TEXT                VARCHAR(MAX)	= '',
          @Ld_High_DATE                DATE			= '12/31/9999',
          @Ld_Current_DATE             DATE			= DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Ls_ParameterDefination_TEXT NVARCHAR(MAX)= ' ',
          @Ls_Query_TEXT			   NVARCHAR(MAX) = ' ';
       
         
       SET @Ls_ParameterDefination_TEXT =	N'@An_Case_IDNO         NUMERIC(6),
											@Ac_ActivityMajor_CODE	CHAR(4),
											@Ac_Subsystem_CODE		CHAR(2),
											@Ac_SortBy_TEXT			CHAR(30),
											@Ac_SortOrder_TEXT		CHAR(4),
											@An_DateDiff_NUMB		NUMERIC(9, 2),
											@Ac_WorkerUpdate_ID		CHAR(30),
											@Ai_RowFrom_NUMB		INT				= 1  ,
											@Ai_RowTo_NUMB			INT				= 10 ,
											@Ld_Current_DATE        DATE';

  IF @Ac_WorkerUpdate_ID IS NOT NULL
   BEGIN
    SET @Ls_WhereWorkerUpdateID_TEXT = 'AND ISNULL(t.WorkerUpdate_ID, a.UserLastPoster_ID) =   @Ac_WorkerUpdate_ID  ';
   END
   
  SET @Lc_SortOrder_TEXT = CASE WHEN @Ac_SortBy_TEXT = 'LastPost_DTTM'
								THEN @Ac_SortOrder_TEXT
								ELSE @Lc_SortOrder_TEXT
						    END;
  SET @Ls_Sql1_TEXT='
      SELECT
		Y.MajorIntSeq_NUMB ,
        Y.MinorIntSeq_NUMB ,
        Y.ActivityMinor_CODE ,
        Y.Status_CODE ,
        Y.Topic_IDNO ,
        Y.UserLastPoster_ID ,
        Y.LastPost_DTTM ,
        Y.TransactionEventSeq_NUMB ,
        Y.ActivityMajor_CODE ,
        Y.Subsystem_CODE ,
        Y.TypeOthpSource_CODE ,
        Y.OthpSource_IDNO ,
		CASE
            WHEN Y.ActivityMinor_CODE = ''' + @Lc_ActivityMinorNOPRI_CODE + '''
            THEN ISNULL(CAST(Y.DescriptionActivityMinor_TEXT AS VARCHAR(75)), ''' + @Lc_Empty_TEXT + ''') + ''' + @Lc_HyphenWithSpace_TEXT + ''' + ISNULL(
               (
                  SELECT
                  	DISTINCT ISNULL(c.Notice_ID, ''' + @Lc_Empty_TEXT + ''') + ''' + @Lc_HyphenWithSpace_TEXT + ''' + ISNULL(b.DescriptionNotice_TEXT, ''' + @Lc_Empty_TEXT + ''')
                   FROM
                  	FORM_Y1  c
                  JOIN
                  	NREF_Y1  b
                  		ON
							c.Notice_ID = b.Notice_ID
                  WHERE
                     c.Topic_IDNO = Y.Topic_IDNO
                  AND
                     b.EndValidity_DATE = ''' + CONVERT(CHAR(10), @Ld_High_DATE) + '''
               ), ''' + @Lc_Empty_TEXT + ''')
            ELSE DescriptionActivityMinor_TEXT
         END AS DescriptionActivityMinor_TEXT,
             (
               SELECT
               	DISTINCT j.DescriptionActivity_TEXT
               FROM
               	AMJR_Y1  j
               WHERE
               	j.ActivityMajor_CODE = Y.ActivityMajor_CODE
               AND
               	j.EndValidity_DATE = ''' + CONVERT(CHAR(10), @Ld_High_DATE) + '''
            ) AS DescriptionActivityMajor_TEXT,
         dbo.BATCH_COMMON$SF_GET_UNCHECKED_FORMS(Y.Topic_IDNO, Y.MemberMci_IDNO, Y.Case_IDNO, Y.ActivityMajor_CODE) AS DescriptionUnCheckedNotices_TEXT,
             Y.DescriptionNote_TEXT,
            CASE 
             WHEN Notice_ID IS NULL 
              THEN ''' + @Lc_NoticeExistsNo_INDC + ''' 
             ELSE ''' + @Lc_NoticeExistsYes_INDC + ''' 
            END NoticeExists_INDC,
             (SELECT r.DescriptionValue_TEXT 
                         FROM REFM_Y1 r 
                       WHERE 
                          r.Table_ID=''' + @Lc_TableCPRO_ID + '''  AND 
                          r.TableSub_ID=''' + @Lc_TableSubREAS_ID + ''' AND 
                          r.Value_CODE=Y.ReasonStatus_CODE
             ) AS DescriptionStatus_TEXT,
          Y.RowCount_NUMB
       FROM
         (
           	SELECT
          		X.DescriptionActivityMinor_TEXT,
                X.Subsystem_CODE,
                X.ActivityMajor_CODE,
                X.ActivityMinor_CODE,
                X.MajorIntSeq_NUMB,
                X.MinorIntSeq_NUMB,
                X.OthpSource_IDNO,
                X.TypeOthpSource_CODE,
                X.TransactionEventSeq_NUMB,
                X.Status_CODE,
                X.Topic_IDNO,
                X.UserLastPoster_ID,
                X.LastPost_DTTM,
                X.Case_IDNO,
                X.MemberMci_IDNO,
                X.ReasonStatus_CODE,
                X.DescriptionNote_TEXT,
                X.RowCount_NUMB,
                (
                  SELECT TOP 1 Notice_ID
                   FROM
                  	FORM_Y1  c
                 WHERE
                     c.Topic_IDNO = X.Topic_IDNO
                ) AS Notice_ID,
                X.ORD_ROWNUM AS row_num
              FROM
              ( SELECT

              			X1.DescriptionActivityMinor_TEXT,
                     X1.Subsystem_CODE ,
                     X1.ActivityMajor_CODE,
                     X1.ActivityMinor_CODE,
                     X1.MajorIntSeq_NUMB,
                     X1.MinorIntSeq_NUMB,
                     X1.OthpSource_IDNO,
                     X1.TypeOthpSource_CODE,
                     X1.TransactionEventSeq_NUMB,
                     X1.Status_CODE,
                     X1.Topic_IDNO,
                     X1.UserLastPoster_ID,
                     X1.LastPost_DTTM,
                     X1.Case_IDNO,
                     X1.MemberMci_IDNO,
                     X1.ReasonStatus_CODE,
                     X1.DescriptionNote_TEXT,
                     COUNT(1) OVER() AS RowCount_NUMB,
                     ROW_NUMBER() OVER (
									ORDER BY ' + @Ac_SortBy_TEXT + ' ' + @Ac_SortOrder_TEXT + ',Topic_IDNO '+@Lc_SortOrder_TEXT+') AS ORD_ROWNUM
                 FROM

               (';

  SET @Ls_Sql2_TEXT='
                   SELECT
                     c.DescriptionActivity_TEXT AS DescriptionActivityMinor_TEXT,
                     a.Subsystem_CODE ,
                     a.ActivityMajor_CODE,
                     a.ActivityMinor_CODE,
                     a.MajorIntSeq_NUMB,
                     a.MinorIntSeq_NUMB,
                     b.OthpSource_IDNO,
                     b.TypeOthpSource_CODE,
                     a.TransactionEventSeq_NUMB,
                     CASE WHEN 
                       a.Status_CODE = ''' + @Lc_StatusExempt_CODE + ''' 
                         THEN ''' + @Lc_StatusComplete_CODE + ''' 
                       ELSE a.Status_CODE 
                     END Status_CODE,
                     a.Topic_IDNO,
                     ISNULL(t.WorkerUpdate_ID, a.UserLastPoster_ID) UserLastPoster_ID,
                     ISNULL(t.Update_DTTM, a.LastPost_DTTM) LastPost_DTTM,
                     ISNULL(t.DescriptionNote_TEXT,'''') DescriptionNote_TEXT,
                     a.Case_IDNO,
                     a.MemberMci_IDNO,
                     a.ReasonStatus_CODE
                   FROM
                  	UDMNR_V1  a
                  JOIN
                  	AMNR_Y1   c
                  		ON
							a.ActivityMinor_CODE = c.ActivityMinor_CODE
                  JOIN
                  	DMJR_Y1   b
                  		ON
							a.Case_IDNO = b.Case_IDNO
						AND
							a.Forum_IDNO = b.Forum_IDNO
				  LEFT JOIN (SELECT n.Topic_IDNO,
									n.DescriptionNote_TEXT,
								    n.WorkerUpdate_ID,
								    n.Update_DTTM,
								    ROW_NUMBER() OVER(PARTITION BY n.Case_IDNO, n.Topic_IDNO ORDER BY n.Post_IDNO DESC) Row_NUMB
								FROM NOTE_Y1 n
							   WHERE n.Case_IDNO =  @An_Case_IDNO
							     AND n.EndValidity_DATE = ''' + CAST(@Ld_High_DATE AS CHAR(10)) + ''' ) t
						ON t.Row_NUMB = 1
					   AND t.Topic_IDNO = a.Topic_IDNO
                  WHERE
                     a.MajorIntSeq_NUMB != 0
                  AND
                     b.Subsystem_CODE LIKE LTRIM(RTRIM(''' + ISNULL(@Ac_Subsystem_CODE, @Lc_Empty_TEXT) + ''')) + ''' + @Lc_Percentage_TEXT + '''
                  AND
                     b.ActivityMajor_CODE LIKE LTRIM(RTRIM(''' + ISNULL(@Ac_ActivityMajor_CODE, @Lc_Empty_TEXT) + ''')) + ''' + @Lc_Percentage_TEXT + '''
                  AND
                     b.ActivityMajor_CODE
						IN
                          (
							SELECT
                        		k.ActivityMajor_CODE
							 FROM
                        		AMJR_Y1 k
							WHERE
                        		k.Subsystem_CODE LIKE LTRIM(RTRIM(''' + ISNULL(@Ac_Subsystem_CODE, @Lc_Empty_TEXT) + ''')) + ''' + @Lc_Percentage_TEXT + '''
						  )
				  AND
                     a.Case_IDNO =  @An_Case_IDNO  
                  AND
                     c.EndValidity_DATE = ''' + CONVERT(CHAR(10), @Ld_High_DATE) + '''
                  AND
                     a.Topic_IDNO
						NOT IN
						  (
							SELECT
                        		g.Topic_IDNO
							 FROM
                        		NMRQ_Y1   e
                        	JOIN
                        		FORM_Y1   f
									ON
										e.Barcode_NUMB = f.Barcode_NUMB
							JOIN
                        		UDMNR_V1  g
									ON
										f.Topic_IDNO = g.Topic_IDNO
							WHERE
							   e.Case_IDNO = @An_Case_IDNO   
							AND
							   e.StatusNotice_CODE = ''' + @Lc_StatusNoticeT_CODE + '''
							AND
							   g.ActivityMinor_CODE = ''' + @Lc_ActivityMinorNOPRI_CODE + '''
                          )
                  AND
                     a.Entered_DATE BETWEEN DATEADD(d,-CAST( @An_DateDiff_NUMB AS FLOAT(53)), @Ld_Current_DATE)  AND @Ld_Current_DATE 
                     ' + @Ls_WhereWorkerUpdateID_TEXT + '
               )  AS X1

              ) AS X
            WHERE
            	X.ORD_ROWNUM <=    @Ai_RowTo_NUMB    
         )  AS Y
      WHERE
      	Y.row_num >=   @Ai_RowFrom_NUMB ';

  set @Ls_Query_TEXT=@Ls_Sql1_TEXT+@Ls_Sql2_TEXT ;
    
   EXEC SP_EXECUTESQL  
  @Ls_Query_TEXT,  
  @Ls_ParameterDefination_TEXT,  
  @An_Case_IDNO=@An_Case_IDNO,
  @Ac_ActivityMajor_CODE=@Ac_ActivityMajor_CODE,
 @Ac_Subsystem_CODE =@Ac_Subsystem_CODE,
 @Ac_SortBy_TEXT  =@Ac_SortBy_TEXT,
 @Ac_SortOrder_TEXT =@Ac_SortOrder_TEXT,
 @An_DateDiff_NUMB =@An_DateDiff_NUMB,
  @Ac_WorkerUpdate_ID =@Ac_WorkerUpdate_ID,
 @Ai_RowFrom_NUMB   =@Ai_RowFrom_NUMB,
 @Ai_RowTo_NUMB    = @Ai_RowTo_NUMB,
 @Ld_Current_DATE=@Ld_Current_DATE;
  
 END; --END OF UDMNR_RETRIEVE_S9


GO
