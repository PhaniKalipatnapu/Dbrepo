/****** Object:  StoredProcedure [dbo].[CSPR_RETRIEVE_S6]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CSPR_RETRIEVE_S6] (
 @Ad_Generated_DATE         DATE,
 @An_Case_IDNO              NUMERIC(6, 0),
 @Ac_IVDOutOfStateFips_CODE CHAR(2),
 @Ac_Function_CODE          CHAR(3),
 @Ac_Action_CODE            CHAR(1),
 @Ac_Reason_CODE            CHAR(5)
 )
AS
 /*
  *     PROCEDURE NAME    : CSPR_RETRIEVE_S6
  *     DESCRIPTION       : Retrieve the NOtice id, category form code, request idno, gernerated date for the given case idno, FAR combination , and the endvalidity date eqal to high date.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 04-OCT-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_High_DATE         DATE = '12/31/9999',
          @Lc_BatchOnlineI_CODE CHAR(1) = 'I',
          @Lc_NoticeInt08_ID    CHAR(6) = 'INT-08',
          @Lc_NoticeInt01_ID    CHAR(6) = 'INT-01',
          @Lc_NoticeInt02_ID    CHAR(6) = 'INT-02',
          @Lc_NoticeInt03_ID    CHAR(6) = 'INT-03',
          @Lc_NoticeInt14_ID    CHAR(6) = 'INT-14';

  SELECT DISTINCT a.Notice_ID,
         b.CategoryForm_CODE,
         b.Category_CODE,
         c.Request_IDNO,
         c.Generated_DATE
    FROM FFCL_Y1 a
         JOIN NREF_Y1 b
          ON a.Notice_ID = b.Notice_ID
         JOIN CSPR_Y1 c
          ON a.Function_CODE = c.Function_CODE
             AND a.Action_CODE = c.Action_CODE
             AND a.Reason_CODE = c.Reason_CODE
   WHERE c.Case_IDNO = @An_Case_IDNO
     AND c.IVDOutOfStateFips_CODE = @Ac_IVDOutOfStateFips_CODE
     AND a.Function_CODE = @Ac_Function_CODE
     AND a.Action_CODE = @Ac_Action_CODE
     AND a.Reason_CODE = @Ac_Reason_CODE
     AND c.Generated_DATE = @Ad_Generated_DATE
     AND a.Notice_ID IN (@Lc_NoticeInt08_ID, @Lc_NoticeInt01_ID, @Lc_NoticeInt02_ID, @Lc_NoticeInt03_ID, @Lc_NoticeInt14_ID)
     AND b.BatchOnline_CODE = @Lc_BatchOnlineI_CODE
     AND a.EndValidity_DATE = @Ld_High_DATE
     AND b.EndValidity_DATE = @Ld_High_DATE
     AND c.EndValidity_DATE = @Ld_High_DATE;
 END; -- End of CSPR_RETRIEVE_S6

GO
