/****** Object:  StoredProcedure [dbo].[OTHP_RETRIEVE_S84]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OTHP_RETRIEVE_S84] (
 @An_OtherParty_IDNO      NUMERIC(9, 0),
 @Ac_Exists_INDC          CHAR(1) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : OTHP_RETRIEVE_S84
  *     DESCRIPTION       : Check if a record exists for an Other Party Idno, Other Party Type, and Other Party Residing State.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-MAR-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN


  DECLARE @Lc_Yes_TEXT         CHAR(1) = 'Y',
          @Lc_No_TEXT          CHAR(1) ='N',
          @Ld_High_DATE        DATE = '12/31/9999',
          @Lc_TypeOthpLab_CODE CHAR(1) = 'L',
          @Lc_StateDe_ADDR     CHAR(2) = 'DE',
          @Lc_ProcessAltp_ID   CHAR(4) = 'ALTP',
          @Lc_TableSltp_ID     CHAR(4) = 'SLTP';
          
   SET @Ac_Exists_INDC = @Lc_No_TEXT;

  SELECT @Ac_Exists_INDC = @Lc_Yes_TEXT
    FROM OTHP_Y1 O
   WHERE O.OtherParty_IDNO = @An_OtherParty_IDNO
     AND O.TypeOthp_CODE IN (SELECT R.Reason_CODE
                               FROM RESF_Y1 R
                              WHERE R.Table_ID = @Lc_TableSltp_ID
                                AND R.Process_ID = @Lc_ProcessAltp_ID)
     AND ((O.State_ADDR = @Lc_StateDe_ADDR
           AND O.TypeOthp_CODE = @Lc_TypeOthpLab_CODE)
           OR O.TypeOthp_CODE != @Lc_TypeOthpLab_CODE)
     AND O.EndValidity_DATE = @Ld_High_DATE;
 END; --END OF OTHP_RETRIEVE_S84


GO
