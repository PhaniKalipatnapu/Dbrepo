/****** Object:  StoredProcedure [dbo].[CFAR_RETRIEVE_S10]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CFAR_RETRIEVE_S10] (
 @An_Case_IDNO          NUMERIC(6, 0),
 @An_RespondentMci_IDNO NUMERIC(10, 0),
 @Ai_RowFrom_NUMB       INT =1,
 @Ai_RowTo_NUMB         INT =10
 )
AS
 /*    
  *     PROCEDURE NAME    : CFAR_RETRIEVE_S10    
  *     DESCRIPTION       : Retrieve Csenet Transaction Header Block details for a Transaction Header Idno, Action Code, Function Code, Case Idno, and Reason Code.    
  *     DEVELOPED BY      : IMP Team    
  *     DEVELOPED ON      : 01-SEP-2011    
  *     MODIFIED BY       :     
  *     MODIFIED ON       :     
  *     VERSION NO        : 1    
  */
 BEGIN
  DECLARE @Lc_IoDirectionOut_CODE             CHAR(1) = 'O',
          @Lc_StatusOpen_CODE                 CHAR(1) = 'O',
          @Lc_IVDOutOfStateCountyFips000_CODE CHAR(3) ='000',
          @Lc_IVDOutOfStateOfficeFips00_CODE  CHAR(2) = '00',
          @Ld_High_DATE                       DATE = '12/31/9999',
          @Lc_IoDirectionIN_CODE              CHAR(1)= 'I',		 
          @Lc_NoticeStartWithINT_ID           CHAR(4) = 'INT%',
		  @Li_Zero_NUMB						  SMALLINT = 0;

  SELECT Z.TransHeader_IDNO,
         Z.IVDOutOfStateFips_CODE,
         Z.IVDOutOfStateCountyFips_CODE,
         Z.IVDOutOfStateOfficeFips_CODE,
         Z.Transaction_DATE,
         Z.IoDirection_CODE,
         Z.IVDOutOfStateCase_ID,
         Z.Function_CODE,
         Z.Action_CODE,
         Z.Reason_CODE,
         Z.RespondentMci_IDNO,
         Z.Case_IDNO,
         Z.ExchangeMode_CODE,
         Z.TranStatus_CODE,
         (SELECT COUNT(1)
            FROM FFCL_Y1 d
           WHERE d.Function_CODE = Z.Function_CODE
             AND d.Action_CODE = Z.Action_CODE
             AND d.Reason_CODE = Z.Reason_CODE
             AND d.Notice_ID LIKE @Lc_NoticeStartWithINT_ID
             AND d.EndValidity_DATE = @Ld_High_DATE) AS NoForms_QNTY,
         (SELECT S.State_NAME
            FROM STAT_Y1 S
           WHERE S.StateFips_CODE = Z.IVDOutOfStateFips_CODE) AS State_NAME,
         Z.DescriptionFar_TEXT,
         Z.Request_IDNO,
         Z.RefAssist_CODE,
         Z.RowCount_NUMB
    FROM (SELECT Y.Transaction_DATE,
                 Y.IVDOutOfStateFips_CODE,
                 Y.IVDOutOfStateCountyFips_CODE,
                 Y.IVDOutOfStateOfficeFips_CODE,
                 Y.Case_IDNO,
                 Y.IVDOutOfStateCase_ID,
                 Y.DescriptionFar_TEXT,
                 Y.TranStatus_CODE,
                 Y.ExchangeMode_CODE,
                 Y.TransHeader_IDNO,
                 Y.Function_CODE,
                 Y.Action_CODE,
                 Y.Reason_CODE,
                 Y.RespondentMci_IDNO,
                 Y.IoDirection_CODE,
                 Y.Request_IDNO,
                 Y.RefAssist_CODE,
                 Y.RowCount_NUMB,
                 Y.ORD_ROWNUM AS row_num
            FROM (SELECT X.Transaction_DATE,
                         X.IVDOutOfStateFips_CODE,
                         X.IVDOutOfStateCountyFips_CODE,
                         X.IVDOutOfStateOfficeFips_CODE,
                         X.Case_IDNO,
                         X.IVDOutOfStateCase_ID,
                         X.DescriptionFar_TEXT,
                         X.TranStatus_CODE,
                         X.ExchangeMode_CODE,
                         X.TransHeader_IDNO,
                         X.Function_CODE,
                         X.Action_CODE,
                         X.Reason_CODE,
                         X.RespondentMci_IDNO,
                         X.IoDirection_CODE,
                         X.Request_IDNO,
                         X.RefAssist_CODE,
                         COUNT(1) OVER() AS RowCount_NUMB,
                         ROW_NUMBER() OVER( ORDER BY X.Transaction_DATE DESC, X.TransHeader_IDNO DESC) AS ORD_ROWNUM
                    FROM ( SELECT W.Transaction_DATE,
                         W.IVDOutOfStateFips_CODE,
                         W.IVDOutOfStateCountyFips_CODE,
                         W.IVDOutOfStateOfficeFips_CODE,
                         W.Case_IDNO,
                         W.IVDOutOfStateCase_ID,
                         W.DescriptionFar_TEXT,
                         W.TranStatus_CODE,
                         W.ExchangeMode_CODE,
                         W.TransHeader_IDNO,
                         W.Function_CODE,
                         W.Action_CODE,
                         W.Reason_CODE,
                         W.RespondentMci_IDNO,
                         W.IoDirection_CODE,
                         W.Request_IDNO,
                         W.RefAssist_CODE
                         FROM (SELECT a.Transaction_DATE,
                                 a.IVDOutOfStateFips_CODE,
                                 ISNULL(a.IVDOutOfStateCountyFips_CODE, @Lc_IVDOutOfStateCountyFips000_CODE)IVDOutOfStateCountyFips_CODE,
                                 ISNULL(a.IVDOutOfStateOfficeFips_CODE, @Lc_IVDOutOfStateOfficeFips00_CODE)IVDOutOfStateOfficeFips_CODE,
                                 a.Case_IDNO,
                                 a.IVDOutOfStateCase_ID,
                                 b.DescriptionFar_TEXT,
                                 a.TranStatus_CODE,
                                 a.ExchangeMode_CODE,
                                 a.TransHeader_IDNO AS TransHeader_IDNO,
                                 a.Function_CODE,
                                 a.Action_CODE,
                                 a.Reason_CODE,
                                 CASE WHEN a.IoDirection_CODE=@Lc_IoDirectionIN_CODE THEN 
											( SELECT ISNULL ( ( SELECT TOP 1 ISNULL(i.RespondentMci_IDNO, NULL)
														FROM ICAS_Y1 i
													 WHERE i.Case_IDNO = a.Case_IDNO
													 AND i.IVDOutOfStateFips_CODE = a.IVDOutOfStateFips_CODE                                    
													 AND i.Status_CODE = @Lc_StatusOpen_CODE
													 AND i.EndValidity_DATE = @Ld_High_DATE )
												   ,
												   ( SELECT TOP 1 ISNULL(C.MemberMci_IDNO , @Li_Zero_NUMB ) 
													     FROM CNCB_Y1 C 
													  WHERE C.TransHeader_IDNO = a.TransHeader_IDNO ) 
												   ) ) 
								      WHEN a.IoDirection_CODE=@Lc_IoDirectionOut_CODE THEN 
											( SELECT b.RespondentMci_IDNO 
											      FROM CSPR_Y1 b 
											    WHERE b.Request_IDNO=CAST(a.Message_ID AS FLOAT(53))
								  )
								 END AS RespondentMci_IDNO,								         
                                 a.IoDirection_CODE,
                                 CAST(a.Message_ID AS FLOAT(53)) AS Request_IDNO,
                                 b.RefAssist_CODE
                            FROM CTHB_Y1 a
                                 JOIN CFAR_Y1 b
                                  ON b.Action_CODE = a.Action_CODE
                                     AND b.Function_CODE = a.Function_CODE
                                     AND b.Reason_CODE = a.Reason_CODE
                           WHERE a.Case_IDNO = @An_Case_IDNO                             
                             AND a.IoDirection_CODE IN ( @Lc_IoDirectionIN_CODE , @Lc_IoDirectionOut_CODE )
                          UNION
                          SELECT a.Generated_DATE,
                                 a.IVDOutOfStateFips_CODE,
                                 a.IVDOutOfStateCountyFips_CODE,
                                 a.IVDOutOfStateOfficeFips_CODE,
                                 a.Case_IDNO,
                                 a.IVDOutOfStateCase_ID,
                                 b.DescriptionFar_TEXT,
                                 a.StatusRequest_CODE,
                                 a.ExchangeMode_INDC,
                                 a.TransHeader_IDNO,
                                 a.Function_CODE,
                                 a.Action_CODE,
                                 a.Reason_CODE,
                                 a.RespondentMci_IDNO,
                                 @Lc_IoDirectionOut_CODE AS IoDirection_CODE,
                                 a.Request_IDNO,
                                 b.RefAssist_CODE
                            FROM CSPR_Y1 a
                                 JOIN CFAR_Y1 b
                                  ON a.Action_CODE = b.Action_CODE
                                     AND a.Function_CODE = b.Function_CODE
                                     AND a.Reason_CODE = b.Reason_CODE
                           WHERE a.EndValidity_DATE = @Ld_High_DATE
						     AND NOT EXISTS ( SELECT 1 FROM CTHB_Y1 c WHERE CAST( c.Message_ID AS CHAR)  = CAST(a.Request_IDNO AS CHAR) )
                             AND a.Case_IDNO = @An_Case_IDNO ) AS W
                             WHERE W.RespondentMCi_IDNO = ISNULL(@An_RespondentMci_IDNO, W.RespondentMCi_IDNO))
                             AS X) AS Y
           WHERE Y.ORD_ROWNUM <= @Ai_RowTo_NUMB) AS Z
   WHERE Z.row_num >= @Ai_RowFrom_NUMB
   ORDER BY ROW_NUM;
 END; --End of CFAR_RETRIEVE_S10 

GO
