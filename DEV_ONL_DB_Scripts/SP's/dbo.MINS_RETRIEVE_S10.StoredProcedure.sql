/****** Object:  StoredProcedure [dbo].[MINS_RETRIEVE_S10]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[MINS_RETRIEVE_S10](
 @An_MemberMci_IDNO        NUMERIC(10, 0),
 @An_OthpInsurance_IDNO    NUMERIC(9, 0),
 @Ac_InsuranceGroupNo_TEXT CHAR(25),
 @Ac_PolicyInsNo_TEXT      CHAR(20),
 @Ad_Begin_DATE            DATE,
 @Ac_Exists_INDC           CHAR(1) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : MINS_RETRIEVE_S10
  *     DESCRIPTION       : Retrieve the count of records from Member Insurance table for Unique number assigned by the system to the participant, Unique number assigned by the system to the Insurance Co. of the Participant, Group number of the Participant Insurance, Policy Number of the Participant and Date at which the Insurance Policy Ends greater than the Date from the which the Insurance Policy Start.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 12-OCT-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  DECLARE @Lc_Space_TEXT CHAR(1) = ' ',
          @Ld_High_DATE  DATE = '12/31/9999',
          @Lc_Yes_INDC   CHAR(1) = 'Y',
          @Lc_No_INDC    CHAR(1) = 'N';

  SET @Ac_Exists_INDC = @Lc_No_INDC;

  SELECT @Ac_Exists_INDC = @Lc_Yes_INDC
    FROM MINS_Y1 MI
   WHERE MI.MemberMci_IDNO = @An_MemberMci_IDNO
     AND MI.OthpInsurance_IDNO = @An_OthpInsurance_IDNO
     AND ISNULL(MI.InsuranceGroupNo_TEXT, @Lc_Space_TEXT) = ISNULL(@Ac_InsuranceGroupNo_TEXT, @Lc_Space_TEXT)
     AND ISNULL(MI.PolicyInsNo_TEXT, @Lc_Space_TEXT) = ISNULL(@Ac_PolicyInsNo_TEXT, @Lc_Space_TEXT)
     AND ISNULL(MI.End_DATE, @Ld_High_DATE) > @Ad_Begin_DATE
     AND MI.EndValidity_DATE = @Ld_High_DATE;
 END -- End of MINS_RETRIEVE_S10

GO
