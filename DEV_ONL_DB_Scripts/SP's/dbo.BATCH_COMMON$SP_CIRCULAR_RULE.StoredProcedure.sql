/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_CIRCULAR_RULE]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_COMMON$SP_CIRCULAR_RULE
Programmer Name		: IMP Team
Description			:  
Frequency			: 
Developed On		:	04/12/2011
Called By			:
Called On			:
--------------------------------------------------------------------------------------------------------------------
Modified By			:
Modified On			:
Version No			: 1.0	
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_CIRCULAR_RULE]
 @An_ArrPaa_AMNT         NUMERIC(11, 2) OUTPUT,
 @An_TransactionPaa_AMNT NUMERIC(11, 2) OUTPUT,
 @An_ArrUda_AMNT         NUMERIC(11, 2) OUTPUT,
 @An_TransactionUda_AMNT NUMERIC(11, 2) OUTPUT,
 @An_ArrNaa_AMNT         NUMERIC(11, 2) OUTPUT,
 @An_TransactionNaa_AMNT NUMERIC(11, 2) OUTPUT,
 @An_ArrCaa_AMNT         NUMERIC(11, 2) OUTPUT,
 @An_TransactionCaa_AMNT NUMERIC(11, 2) OUTPUT,
 @An_ArrUpa_AMNT         NUMERIC(11, 2) OUTPUT,
 @An_TransactionUpa_AMNT NUMERIC(11, 2) OUTPUT,
 @An_ArrTaa_AMNT         NUMERIC(11, 2) OUTPUT,
 @An_TransactionTaa_AMNT NUMERIC(11, 2) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Ln_ArrTot_AMNT NUMERIC (11, 2) = 0;

  IF @An_ArrPaa_AMNT < 0
   BEGIN
    SET @Ln_ArrTot_AMNT = @An_ArrPaa_AMNT;
    SET @An_TransactionPaa_AMNT = @An_TransactionPaa_AMNT - @An_ArrPaa_AMNT;
    SET @An_ArrPaa_AMNT = 0;

    IF @An_ArrUda_AMNT > 0
     BEGIN
      SET @Ln_ArrTot_AMNT = @Ln_ArrTot_AMNT + @An_ArrUda_AMNT;

      IF @Ln_ArrTot_AMNT <= 0
       BEGIN
        SET @An_TransactionUda_AMNT = @An_TransactionUda_AMNT - @An_ArrUda_AMNT;
        SET @An_ArrUda_AMNT = 0;
       END
      ELSE
       BEGIN
        SET @An_TransactionUda_AMNT = @An_TransactionUda_AMNT - @An_ArrUda_AMNT + @Ln_ArrTot_AMNT;
        SET @An_ArrUda_AMNT = @Ln_ArrTot_AMNT;
        SET @Ln_ArrTot_AMNT = 0;
       END
     END

    IF @Ln_ArrTot_AMNT <= 0
     BEGIN
      SET @Ln_ArrTot_AMNT = @Ln_ArrTot_AMNT + @An_ArrNaa_AMNT;
      SET @An_TransactionNaa_AMNT = @An_TransactionNaa_AMNT - @An_ArrNaa_AMNT + @Ln_ArrTot_AMNT;
      SET @An_ArrNaa_AMNT = @Ln_ArrTot_AMNT;
      SET @Ln_ArrTot_AMNT = 0;
     END
   END

  SET @Ln_ArrTot_AMNT = 0;

  IF @An_ArrUda_AMNT < 0
   BEGIN
    SET @Ln_ArrTot_AMNT = @An_ArrUda_AMNT;
    SET @An_TransactionUda_AMNT = @An_TransactionUda_AMNT - @An_ArrUda_AMNT;
    SET @An_ArrUda_AMNT = 0;

    IF @An_ArrPaa_AMNT > 0
     BEGIN
      SET @Ln_ArrTot_AMNT = @Ln_ArrTot_AMNT + @An_ArrPaa_AMNT;

      IF @Ln_ArrTot_AMNT <= 0
       BEGIN
        SET @An_TransactionPaa_AMNT = @An_TransactionPaa_AMNT - @An_ArrPaa_AMNT;
        SET @An_ArrPaa_AMNT = 0;
       END
      ELSE
       BEGIN
        SET @An_TransactionPaa_AMNT = @An_TransactionPaa_AMNT - @An_ArrPaa_AMNT + @Ln_ArrTot_AMNT;
        SET @An_ArrPaa_AMNT = @Ln_ArrTot_AMNT;
        SET @Ln_ArrTot_AMNT = 0;
       END
     END

    IF @Ln_ArrTot_AMNT < 0
     BEGIN
      SET @Ln_ArrTot_AMNT = @Ln_ArrTot_AMNT + @An_ArrNaa_AMNT;
      SET @An_TransactionNaa_AMNT = @An_TransactionNaa_AMNT - @An_ArrNaa_AMNT + @Ln_ArrTot_AMNT;
      SET @An_ArrNaa_AMNT = @Ln_ArrTot_AMNT;
      SET @Ln_ArrTot_AMNT = 0;
     END
   END

  SET @Ln_ArrTot_AMNT = 0;

  IF @An_ArrNaa_AMNT < 0
   BEGIN
    SET @Ln_ArrTot_AMNT = @An_ArrNaa_AMNT;
    SET @An_TransactionNaa_AMNT = @An_TransactionNaa_AMNT - @An_ArrNaa_AMNT;
    SET @An_ArrNaa_AMNT = 0;

    IF @Ln_ArrTot_AMNT < 0
       AND @An_ArrCaa_AMNT > 0
     BEGIN
      SET @Ln_ArrTot_AMNT = @Ln_ArrTot_AMNT + @An_ArrCaa_AMNT;

      IF @Ln_ArrTot_AMNT <= 0
       BEGIN
        SET @An_TransactionCaa_AMNT = @An_TransactionCaa_AMNT - @An_ArrCaa_AMNT;
        SET @An_ArrCaa_AMNT = 0;
       END
      ELSE
       BEGIN
        SET @An_TransactionCaa_AMNT = @An_TransactionCaa_AMNT - @An_ArrCaa_AMNT + @Ln_ArrTot_AMNT;
        SET @An_ArrCaa_AMNT = @Ln_ArrTot_AMNT;
        SET @Ln_ArrTot_AMNT = 0;
       END
     END

    IF @Ln_ArrTot_AMNT < 0
       AND @An_ArrTaa_AMNT > 0
     BEGIN
      SET @Ln_ArrTot_AMNT = @Ln_ArrTot_AMNT + @An_ArrTaa_AMNT;

      IF @Ln_ArrTot_AMNT <= 0
       BEGIN
        SET @An_TransactionTaa_AMNT = @An_TransactionTaa_AMNT - @An_ArrTaa_AMNT;
        SET @An_ArrTaa_AMNT = 0;
       END
      ELSE
       BEGIN
        SET @An_TransactionTaa_AMNT = @An_TransactionTaa_AMNT - @An_ArrTaa_AMNT + @Ln_ArrTot_AMNT;
        SET @An_ArrTaa_AMNT = @Ln_ArrTot_AMNT;
        SET @Ln_ArrTot_AMNT = 0;
       END
     END

    IF @Ln_ArrTot_AMNT < 0
       AND @An_ArrUda_AMNT > 0
     BEGIN
      SET @Ln_ArrTot_AMNT = @Ln_ArrTot_AMNT + @An_ArrUda_AMNT;

      IF @Ln_ArrTot_AMNT <= 0
       BEGIN
        SET @An_TransactionUda_AMNT = @An_TransactionUda_AMNT - @An_ArrUda_AMNT;
        SET @An_ArrUda_AMNT = 0;
       END
      ELSE
       BEGIN
        SET @An_TransactionUda_AMNT = @An_TransactionUda_AMNT - @An_ArrUda_AMNT + @Ln_ArrTot_AMNT;
        SET @An_ArrUda_AMNT = @Ln_ArrTot_AMNT;
        SET @Ln_ArrTot_AMNT = 0;
       END
     END

    IF @Ln_ArrTot_AMNT < 0
       AND @An_ArrPaa_AMNT > 0
     BEGIN
      SET @Ln_ArrTot_AMNT = @Ln_ArrTot_AMNT + @An_ArrPaa_AMNT;

      IF @Ln_ArrTot_AMNT <= 0
       BEGIN
        SET @An_TransactionPaa_AMNT = @An_TransactionPaa_AMNT - @An_ArrPaa_AMNT;
        SET @An_ArrPaa_AMNT = 0;
       END
      ELSE
       BEGIN
        SET @An_TransactionPaa_AMNT = @An_TransactionPaa_AMNT - @An_ArrPaa_AMNT + @Ln_ArrTot_AMNT;
        SET @An_ArrPaa_AMNT = @Ln_ArrTot_AMNT;
        SET @Ln_ArrTot_AMNT = 0;
       END
     END

    IF @Ln_ArrTot_AMNT < 0
     BEGIN
      SET @Ln_ArrTot_AMNT = @Ln_ArrTot_AMNT + @An_ArrNaa_AMNT;
      SET @An_TransactionNaa_AMNT = @An_TransactionNaa_AMNT - @An_ArrNaa_AMNT + @Ln_ArrTot_AMNT;
      SET @An_ArrNaa_AMNT = @Ln_ArrTot_AMNT;
      SET @Ln_ArrTot_AMNT = 0;
     END
   END
 END


GO
