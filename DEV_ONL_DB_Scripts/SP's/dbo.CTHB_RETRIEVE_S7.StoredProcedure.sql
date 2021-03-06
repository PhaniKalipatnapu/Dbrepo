/****** Object:  StoredProcedure [dbo].[CTHB_RETRIEVE_S7]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CTHB_RETRIEVE_S7] (
 @Ac_IVDOutOfStateCase_ID   CHAR(15),
 @Ac_IVDOutOfStateFips_CODE CHAR(2),
 @Ac_RefAssist_CODE         CHAR(2),
 @Ai_RowFrom_NUMB           INT		= 1,
 @Ai_RowTo_NUMB             INT		= 10
 )
AS
 /*    
  *     PROCEDURE NAME    : CTHB_RETRIEVE_S7    
  *     DESCRIPTION       : Retrieve Csenet Trans Header Block details for a Other State Fips Code, Other Case Idno, Action Code, Function Code, and Reason Code. 
  *     DEVELOPED BY      : IMP Team  
  *     DEVELOPED ON      : 02-SEP-2011    
  *     MODIFIED BY       :     
  *     MODIFIED ON       :     
  *     VERSION NO        : 1    
  */
 BEGIN
  DECLARE @Li_Zero_NUMB				SMALLINT	= 0,
          @Lc_Yes_INDC				CHAR(1)		= 'Y',
          @Lc_No_INDC				CHAR(1)		= 'N',
          @Lc_NoticeStart_ID		CHAR(8)		= 'Cs_AMNT%',
          @Lc_WorkerUpdateBatch_ID	CHAR(5)		= 'BATCH',
          @Ld_High_DATE				DATE		= '12/31/9999',
          @Ld_System_DATE			DATE		= DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
          

  SELECT Y.Transaction_DATE,
         Y.IVDOutOfStateFips_CODE,
         Y.IVDOutOfStateCountyFips_CODE,
         Y.IVDOutOfStateOfficeFips_CODE,
         Y.State_NAME,
         Y.Case_IDNO,
         Y.IVDOutOfStateCase_ID,
         Y.Received_DTTM,
         Y.DescriptionFar_TEXT,
         Y.TranStatus_CODE,
         Y.ExchangeMode_CODE,
         Y.TransHeader_IDNO,
         Y.Function_CODE,
         Y.Action_CODE,
         Y.Reason_CODE,
         (SELECT COUNT (1)
            FROM FFCL_Y1 c
           WHERE c.Function_CODE = Y.Function_CODE
             AND c.Action_CODE = Y.Action_CODE
             AND c.Reason_CODE = Y.Reason_CODE
             AND c.Notice_ID LIKE @Lc_NoticeStart_ID
             AND c.EndValidity_DATE = @Ld_High_DATE) AS NoForms_QNTY,
         Y.IoDirection_CODE,
         (SELECT TOP 1 F.TypeAddress_CODE
            FROM FIPS_Y1 F
           WHERE F.StateFips_CODE = Y.IVDOutOfStateFips_CODE
             AND F.CountyFips_CODE = Y.IVDOutOfStateCountyFips_CODE
             AND F.OfficeFips_CODE = Y.IVDOutOfStateOfficeFips_CODE
             AND F.EndValidity_DATE = @Ld_High_DATE) TypeAddress_CODE,
          Y.First_NAME,              
          Y.Last_NAME, 
		  Y.Middle_NAME,
          Y.Suffix_NAME,
          Y.Birth_DATE,
          Y.Access_INDC,
          Y.RowCount_NUMB
    FROM (SELECT X.Transaction_DATE,
                 X.IVDOutOfStateFips_CODE,
                 X.IVDOutOfStateCountyFips_CODE,
                 X.IVDOutOfStateOfficeFips_CODE,
                 X.State_NAME,
                 X.Case_IDNO,
                 X.IVDOutOfStateCase_ID,
                 X.Received_DTTM,
                 X.DescriptionFar_TEXT,
                 X.TranStatus_CODE,
                 X.ExchangeMode_CODE,
                 X.TransHeader_IDNO,
                 X.Function_CODE,
                 X.Action_CODE,
                 X.Reason_CODE,
                 X.IoDirection_CODE,
                 X.First_NAME,              
                 X.Last_NAME, 
				 X.Middle_NAME,
                 X.Suffix_NAME,
                 X.Birth_DATE,
                 CASE WHEN dbo.BATCH_COMMON$SF_CALCULATE_NTH_BDAY(TransactionMin_DATE, 10) < @Ld_System_DATE
					  THEN @Lc_Yes_INDC
					  ELSE @Lc_No_INDC
				 END Access_INDC,
                 X.RowCount_NUMB,
                 X.ORD_ROWNUM AS row_num
            FROM (SELECT a.Transaction_DATE,
                         a.IVDOutOfStateFips_CODE,
                         a.IVDOutOfStateCountyFips_CODE,
                         a.IVDOutOfStateOfficeFips_CODE,
                         s.State_NAME,
                         a.Case_IDNO,
                         a.IVDOutOfStateCase_ID,
                         b.DescriptionFar_TEXT,
                         a.TranStatus_CODE,
                         a.ExchangeMode_CODE,
                         a.TransHeader_IDNO,
                         a.Function_CODE,
                         a.Action_CODE,
                         a.Reason_CODE,
                         a.IoDirection_CODE,
                         CONVERT(DATE, a.Received_DTTM) AS Received_DTTM,
                         c.First_NAME,              
                         c.Last_NAME, 
						 c.Middle_NAME,
                         c.Suffix_NAME,
                         c.Birth_DATE,
                         MIN(a.Transaction_DATE) OVER() TransactionMin_DATE,
                         COUNT(1) OVER() AS RowCount_NUMB,
                         ROW_NUMBER() OVER( ORDER BY a.Transaction_DATE DESC, s.State_NAME ASC) AS ORD_ROWNUM
                    FROM CTHB_Y1 a
                         LEFT OUTER JOIN STAT_Y1 s
                          ON ( s.StateFips_CODE = a.IVDOutOfStateFips_CODE)
                           LEFT OUTER JOIN CNCB_Y1 c
                          ON ( c.TransHeader_IDNO       = a.TransHeader_IDNO
                           AND c.IVDOutOfStateFips_CODE = a.IVDOutOfStateFips_CODE 
                           AND c.Transaction_DATE       = a.Transaction_DATE )
                         JOIN CFAR_Y1 b
                          ON( a.Action_CODE = b.Action_CODE
                             AND a.Function_CODE = b.Function_CODE
                             AND a.Reason_CODE = b.Reason_CODE )
                   WHERE a.IVDOutOfStateFips_CODE = ISNULL(@Ac_IVDOutOfStateFips_CODE, a.IVDOutOfStateFips_CODE)
                     AND a.IVDOutOfStateCase_ID = ISNULL(@Ac_IVDOutOfStateCase_ID, a.IVDOutOfStateCase_ID)
                     AND b.RefAssist_CODE = @Ac_RefAssist_CODE
                     AND a.Case_IDNO = @Li_Zero_NUMB
                     AND a.Trans3Printed_INDC <> @Lc_Yes_INDC ) AS X 
           WHERE X.ORD_ROWNUM <= @Ai_RowTo_NUMB) AS Y
   WHERE Y.row_num >= @Ai_RowFrom_NUMB
   ORDER BY Transaction_DATE DESC,
            State_NAME ASC;
 END; --End of CTHB_RETRIEVE_S7    


GO
