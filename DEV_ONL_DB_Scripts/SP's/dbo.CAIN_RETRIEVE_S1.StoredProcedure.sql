/****** Object:  StoredProcedure [dbo].[CAIN_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CAIN_RETRIEVE_S1] (
 @An_Case_IDNO	             NUMERIC(6,0),
 @Ac_IVDOutOfStateFips_CODE  CHAR(2) 
 )
AS
 /*
  *     PROCEDURE NAME    : CAIN_RETRIEVE_S1
  *     DESCRIPTION       : To show the Attachment Tab Unchecked Forms in Comments Text Area.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 21-AUG-2012
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  DECLARE @Lc_ReceivedNo_INDC            CHAR(1) = 'N',
          @Lc_RefAssistR_CODE            CHAR(1) = 'R',
          @Lc_RespondInitInstate_CODE    CHAR(1) = 'N',
          @Ld_High_DATE                  DATE = '12/31/9999',
          @Lc_TableImcl_ID               CHAR(4) = 'IMCL',
          @Lc_TableSubUifs_ID            CHAR(4) = 'UIFS';

  SELECT a.Notice_ID,
         ISNULL ((SELECT b.DescriptionValue_TEXT
                    FROM REFM_Y1 b
                   WHERE b.Value_CODE = a.Notice_ID
                     AND Table_ID = @Lc_TableImcl_ID
                     AND TableSub_ID = @Lc_TableSubUifs_ID), (SELECT n.DescriptionNotice_TEXT
                                                                FROM NREF_Y1 n
                                                               WHERE n.Notice_ID = a.Notice_ID
                                                                 AND Endvalidity_DATE = @Ld_High_DATE)) AS DescriptionValue_TEXT
         FROM CAIN_Y1 a
         JOIN CTHB_Y1 c
          ON c.TransHeader_IDNO = a.TransHeader_IDNO
             AND c.Transaction_DATE = a.Transaction_DATE
             AND c.IVDOutOfStateFips_CODE = a.IVDOutOfStateFips_CODE
         JOIN CFAR_Y1 b
          ON b.Action_CODE = c.Action_CODE
             AND b.Function_CODE = c.Function_CODE
             AND b.Reason_CODE = c.Reason_CODE
   WHERE c.Case_IDNO=@An_Case_IDNO
     AND a.IVDOutOfStateFips_CODE=@Ac_IVDOutOfStateFips_CODE
     AND a.Received_INDC = @Lc_ReceivedNo_INDC
     AND a.EndValidity_DATE = @Ld_High_DATE
     AND b.RefAssist_CODE = @Lc_RefAssistR_CODE
     AND EXISTS (SELECT 1
                   FROM ICAS_Y1 S
                  WHERE c.Case_IDNO = s.Case_IDNO
                    AND s.RespondInit_CODE <> @Lc_RespondInitInstate_CODE
                    AND s.EndValidity_DATE = @Ld_High_DATE);
 END; --End of CAIN_RETRIEVE_S1

GO
