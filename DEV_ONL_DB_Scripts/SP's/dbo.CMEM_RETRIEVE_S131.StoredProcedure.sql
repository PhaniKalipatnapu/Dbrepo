/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S131]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CMEM_RETRIEVE_S131](
 @An_MemberMci_IDNO NUMERIC(10, 0),
 @Ac_Exists_INDC    CHAR(1) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : CMEM_RETRIEVE_S131
  *     DESCRIPTION       : Retrieve the count of records from Case Members table for the Active (A) Dependant (D) Member whose Case is Open (O) in Case Details table with Respond Init Code equal to Initiation (I) / Responding (R) in both Case Details table and Interstate Cases table whose Sequence Event Transaction equal to maximum of Unique Sequence Number that will be generated for any given Transaction on the Table in Interstate Cases table for the Open (O) Case in Case Details table.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 12-OCT-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  DECLARE @Lc_StatusCaseOpen_CODE        CHAR(1) = 'O',
          @Lc_RespondInitInitiate_CODE   CHAR(1) = 'I',
          @Lc_RespondInitC_CODE          CHAR(1) = 'C',
          @Lc_RespondInitT_CODE          CHAR(1) = 'T',
          @Lc_RespondInitS_CODE          CHAR(1) = 'S',
          @Lc_RespondInitY_CODE          CHAR(1) = 'Y',
          @Lc_RespondInitResponding_CODE CHAR(1) = 'R',
          @Lc_CaseMembeStatusActive_CODE CHAR(1) = 'A',
          @Ld_High_DATE                  DATE = '12/31/9999',
          @Lc_Yes_INDC                   CHAR(1) = 'Y',
          @Lc_No_INDC                    CHAR(1) = 'N';

  SET @Ac_Exists_INDC = @Lc_No_INDC;

  SELECT TOP 1 @Ac_Exists_INDC = @Lc_Yes_INDC
    FROM CMEM_Y1 CM
         JOIN CASE_Y1 C
          ON CM.Case_IDNO = C.Case_IDNO
         JOIN ICAS_Y1 IC
          ON CM.Case_IDNO = IC.Case_IDNO
             AND C.RespondInit_CODE = IC.RespondInit_CODE
   WHERE CM.MemberMci_IDNO = @An_MemberMci_IDNO
     AND C.RespondInit_CODE IN (@Lc_RespondInitInitiate_CODE, @Lc_RespondInitC_CODE, @Lc_RespondInitT_CODE, @Lc_RespondInitResponding_CODE,@Lc_RespondInitS_CODE, @Lc_RespondInitY_CODE)
     AND CM.CaseMemberStatus_CODE = @Lc_CaseMembeStatusActive_CODE
     AND C.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
     AND IC.EndValidity_DATE = @Ld_High_DATE
     AND IC.TransactionEventSeq_NUMB = (SELECT MAX(ICI.TransactionEventSeq_NUMB)
                                          FROM ICAS_Y1 ICI
                                         WHERE ICI.Case_IDNO = CM.Case_IDNO
                                           AND ICI.EndValidity_DATE = @Ld_High_DATE);
 END -- End of CMEM_RETRIEVE_S131

GO
